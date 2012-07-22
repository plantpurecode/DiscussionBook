//
//  FBPost+DiscussionBook.h
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "FBPost.h"

@interface FBPost (DiscussionBook)

- (BOOL)hasComputedHeightForWidth:(CGFloat)width;
- (CGFloat)computedHeightForWidth:(CGFloat)width;
- (void)requestComputedHeightForWidth:(CGFloat)width inFont:(UIFont *)font handler:(void(^)(CGFloat height))handler;

@end
