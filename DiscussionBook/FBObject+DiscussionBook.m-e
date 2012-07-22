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

UIKIT_STATIC_INLINE NSDictionary *DBRecursivePropertiesForSubclassesOfClass(Class cls) {
    NSMutableDictionary *props = [NSMutableDictionary new];
    while ([cls isKindOfClass:[FBObject class]]) {
        [props addEntriesFromDictionary:DBPropertiesForClass(cls)];
        
        cls = [cls superclass];
    }
    
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
    id properties = objc_getAssociatedObject(self, &FBObjectClassPropertiesKey);
    if(!properties) {
        properties = DBRecursivePropertiesForSubclassesOfClass([self class]);
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
            if([propMapping count]) {
                [mergedMapping addEntriesFromDictionary:propMapping];
            }
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
    if ([results count] > 0) {
        return [results objectAtIndex:0];
    } else {
        FBObject *object = [[FBObject alloc] initWithDictionary:dictionary inManagedObjectContext:context];
        return object;
    }
    
}

- (id)initWithDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class])
                                              inManagedObjectContext:context];
    
    self = [[[self class] alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    if(self) {
        [self mapPropertiesWithDictionary:dictionary];
    }
    return self;
}

#pragma mark Private

- (void)mapPropertiesWithDictionary:(NSDictionary *)dict {
    NSDictionary *mapping = [[self class] mergedPropertyMapping];
    if(![mapping count]) return;
    
    for(id key in mapping) {
        id value = [dict objectForKey:key];
        id propertyName = [mapping objectForKey:key];
        id mappedObject = [self mappedObject:value toType:[self class] forPropertyName:propertyName];
        
        if(mappedObject) {
            [self setValue:mappedObject forKey:propertyName];
        }
    }
}

- (id)mappedObject:(id)object toType:(Class)cls forPropertyName:(id)key {
    id mappedObject    = object;
    Class objectType   = [object class];
    Class propertyType = [[cls properties] objectForKey:key];
    
    if(objectType == [NSNull class]) {
        return nil;
    }
    
    if(propertyType == [NSDate class] && objectType == [NSString class]) {
        //NSDateFormatter
        mappedObject = [DBDateFormatter() dateFromString:object];
    } else if(propertyType == [NSDate class] && objectType == [NSString class]) {
        //-description
    } else if([propertyType isSubclassOfClass:[FBObject class]]) {
        //To-one relationship
        mappedObject = [[propertyType alloc] initWithDictionary:object
                                         inManagedObjectContext:[self managedObjectContext]];
    } else if([propertyType isSubclassOfClass:[NSSet class]] && objectType == [NSArray class]) {
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
