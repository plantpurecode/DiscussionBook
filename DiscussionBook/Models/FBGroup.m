//
//  FBGroup.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/20/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "FBGroup.h"
#import "FBPost.h"


@implementation FBGroup

@dynamic name;
@dynamic posts;

+ (NSDictionary *)propertyMapping {
    return @{ @"name" : @"name" };
}

@end
