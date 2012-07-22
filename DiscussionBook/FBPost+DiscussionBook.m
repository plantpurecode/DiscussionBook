//
//  FBPost+DiscussionBook.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "FBPost+DiscussionBook.h"
#import "FBObject+DiscussionBook.h"
#import "FBUser+DiscussionBook.h"

@implementation FBPost (DiscussionBook)

+ (NSDictionary *)propertyMapping {
    return @{
        @"created_time" : @"creationDate",
        @"updated_time" : @"updatedDate",
        @"message" : @"message"
    };
}

- (id)initWithDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    self = [super initWithDictionary:dictionary inManagedObjectContext:context];
    if (self) {
        NSDictionary *fromData = dictionary[@"from"];
        FBUser *user = [FBUser objectWithDictionary:fromData inContext:context];
        [self setValue:user forKey:@"fromUser"];
    }
    return self;
}

@end
