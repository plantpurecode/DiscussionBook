//
//  FBUser+DiscussionBook.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "FBUser+DiscussionBook.h"
#import "FBObject+DiscussionBook.h"

@implementation FBUser (DiscussionBook)

+ (id)objectWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
    id object = [super objectWithDictionary:dictionary inContext:context];
    return object;
}

+ (NSDictionary *)propertyMapping {
    return @{ @"name" : @"name" };
}

@end
