//
//  FBObject.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/20/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "FBObject.h"
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
        NSString *attributes = [NSString stringWithCString:property_getAttributes(prop)
                                                  encoding:NSUTF8StringEncoding];
        if(attributes) {
            //Only add object properties
            BOOL shouldAddProperty = [[attributes substringToIndex:2] isEqualToString:@"T@"];
            
            //Don't add readonly properties
            NSRange rangeOfFirstComma = [attributes rangeOfString:@","];
            if(shouldAddProperty && rangeOfFirstComma.location != NSNotFound) {
                NSRange rangeOfFirstComma = [attributes rangeOfString:@","];
                NSRange rng = NSMakeRange(rangeOfFirstComma.location, rangeOfFirstComma.location + 2);
                shouldAddProperty = ![[attributes substringWithRange:rng] isEqualToString:@"R"];
            }
            
            if(shouldAddProperty) {
                NSString *className = [attributes substringWithRange:NSMakeRange(2, [attributes length] - 3)];
                Class cls = NSClassFromString(className);
                
                if(cls) {
                    [props setObject:cls forKey:name];
                }
            }
        }
    }

    return [props copy];
}

UIKIT_STATIC_INLINE NSDictionary *DBRecursivePropertiesForSubclassesOfClass(Class cls) {
    NSMutableDictionary *props = [NSMutableDictionary new];
    while ([cls superclass] != [NSObject class]) {
        [props addEntriesFromDictionary:DBPropertiesForClass(cls)];
        
        cls = [cls superclass];
    }
    
    return [props copy];
}

static const char FBObjectClassPropertyMappingKey;
static const char FBObjectClassPropertiesKey;

@implementation FBObject

@dynamic identifier;

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
        while(cls != [FBObject class]) {
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
    
    if(propertyType == [NSString class] && objectType == [NSDate class]) {
        //NSDateFormatter
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
