//
//  NSArray+DiscussionBook.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "NSArray+DiscussionBook.h"

@implementation NSArray (DiscussionBook)

- (NSArray *)arrayByMappingArrayWithBlock:(id(^)(id obj))block {
    if(!block) {
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray new];
    for(id object in self) {
        [array addObject:block(object)];
    }
    
    return [array copy];
}

@end
