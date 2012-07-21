//
//  FBPost.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/20/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "FBPost.h"

@implementation FBPost

@dynamic createdDate;
@dynamic message;
@dynamic fromUser;

+ (NSDictionary *)propertyMapping {
    return @{
        @"updated_time": @"created_time",
        @"message" : @"message",
        @"from" : @"fromUser"
    };
}

@end
