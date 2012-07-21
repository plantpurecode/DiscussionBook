//
//  FBUser.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "FBUser.h"

@implementation FBUser

@dynamic name;

+ (NSDictionary *)propertyMapping {
    return @{ @"name" : @"name" };
}

@end
