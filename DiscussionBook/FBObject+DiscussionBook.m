//
//  FBObject+DiscussionBook.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "FBObject+DiscussionBook.h"
#import "NSArray+DiscussionBook.h"
#import <objc/runtime.h>

UIKIT_STATIC_INLINE NSDictionary *DBPropertiesForClass(Class cls) {
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
    if(propertyCount == 0) {
        return nil;
    }
    
    NSMutableDictionary *props = [NSMutableDictionary new];
    for(unsigned i = 0; i < propertyCount; ++i) {
        objc_property_t prop = properties[i];
        
        NSString *name = [[NSString alloc] initWithCString:property_getName(prop) encoding:NSUTF8StringEncoding];
        char *typeStr = property_copyAttributeValue(prop, "T");
        if(typeStr[0] == '@' && strlen(typeStr) > 3) {
            //Only add object properties
            NSString *className = [[NSString alloc] initWithBytes:typeStr+2 length:strlen(typeStr)-3 encoding:NSASCIIStringEncoding];
            Class cls = NSClassFromString(className);
            if (cls) {
                [props setObject:cls forKey:name];
            }
        }
        free(typeStr);
    }
    free(properties);
    
    return [props copy];
}

static NSDateFormatter *DBDateFormatter() {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [formatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [formatter setDateFormat:@"y-MM-dd'T'HH:mm:ssZZZ"];
    });
    return formatter;
}

static const char FBObjectClassPropertyMappingKey;
static const char FBObjectClassPropertiesKey;

@implementation FBObject (DiscussionBook)

+ (NSDictionary *)properties {
    NSMutableDictionary *properties = objc_getAssociatedObject(self, &FBObjectClassPropertiesKey);
    if(!properties) {
        properties = [NSMutableDictionary dictionary];
        Class cls = [self class];
        while (cls != [FBObject superclass]) {
            NSDictionary *p = DBPropertiesForClass(cls);
            [properties addEntriesFromDictionary:p];
            cls = [cls superclass];
        }
        objc_setAssociatedObject(self, &FBObjectClassPropertiesKey, properties, OBJC_ASSOCIATION_RETAIN);
    }
    
    return properties;
}

+ (NSDictionary *)mergedPropertyMapping {
    id mapping = objc_getAssociatedObject(self, &FBObjectClassPropertyMappingKey);
    if(!mapping) {
        Class cls = [self class];
        NSMutableDictionary *mergedMapping = [NSMutableDictionary new];
        while(cls != [FBObject superclass]) {
            NSDictionary *propMapping = [cls propertyMapping];
            [mergedMapping addEntriesFromDictionary:propMapping];
            cls = [cls superclass];
        }
        mapping = [mergedMapping copy];
        objc_setAssociatedObject(self, &FBObjectClassPropertyMappingKey, mapping, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return mapping;
}

+ (NSDictionary *)propertyMapping {
    return @{ @"id" : @"identifier"};
}

+ (id)objectWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fr = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass(self)];
    [fr setPredicate:[NSPredicate predicateWithFormat:@"identifier = %@", dictionary[@"id"]]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fr error:&error];
    
    FBObject *object = nil;
    if ([results count] > 0) {
        object = [results objectAtIndex:0];
        [object mergeDataFromDictionary:dictionary];
    } else {
        object = [[self alloc] initWithDictionary:dictionary inManagedObjectContext:context];
    }
    return object;
    
}

- (id)initWithDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class])
                                              inManagedObjectContext:context];
    
    self = [[[self class] alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    if(self) {
        [self mergeDataFromDictionary:dictionary];
    }
    return self;
}

- (void)mergeDataFromDictionary:(NSDictionary *)dictionary {
    [self mapPropertiesWithDictionary:dictionary];
}

#pragma mark Private

- (void)mapPropertiesWithDictionary:(NSDictionary *)dict {
    NSDictionary *mapping = [[self class] mergedPropertyMapping];
    if(![mapping count]) return;
    
    for(id key in mapping) {
        @try {
            id value = [dict valueForKeyPath:key];
            id propertyName = [mapping objectForKey:key];
            id mappedObject = [self mappedObject:value forPropertyName:propertyName];
            
            if(mappedObject && [mappedObject isKindOfClass:[NSDictionary class]] == NO) {
                [self setValue:mappedObject forKey:propertyName];
            }
        }
        @catch (NSException *e) {
            // consume
        }
    }
}

- (id)mappedObject:(id)object forPropertyName:(id)key {
    id mappedObject    = object;
    Class propertyType = [[[self class] properties] objectForKey:key];
    
    if(object == [NSNull null]) {
        return nil;
    }
    
    if(propertyType == [NSDate class] && [object isKindOfClass:[NSString class]]) {
        //NSDateFormatter
        mappedObject = [DBDateFormatter() dateFromString:object];
    } else if(propertyType == [NSString class] && [object isKindOfClass:[NSDate class]]) {
        //-description
        mappedObject = [object description];
    } else if([propertyType isSubclassOfClass:[FBObject class]]) {
        //To-one relationship
        mappedObject = [[propertyType alloc] initWithDictionary:object
                                         inManagedObjectContext:[self managedObjectContext]];
    } else if([propertyType isSubclassOfClass:[NSSet class]] && [object isKindOfClass:[NSArray class]]) {
        //To-many relationship
        NSRelationshipDescription *relationshipDescription = [[[self entity] relationshipsByName] objectForKey:key];
        Class entity = NSClassFromString([[relationshipDescription destinationEntity] name]);
        
        if(entity) {
            mappedObject = [object arrayByMappingArrayWithBlock:^id(id obj) {
                return [[entity alloc] initWithDictionary:obj
                                   inManagedObjectContext:[self managedObjectContext]];
            }];
        }
    }
    
    return mappedObject;
}

@end
