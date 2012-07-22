//
//  FBGroup+DiscussionBook.h
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "FBGroup.h"

@class DBRequest;
@interface FBGroup (DiscussionBook)

- (DBRequest *)requestThreads:(void(^)(NSArray *threads))handler;

@end
