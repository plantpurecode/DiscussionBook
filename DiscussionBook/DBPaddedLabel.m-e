//
//  DBPaddedLabel.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "DBPaddedLabel.h"

@implementation DBPaddedLabel

- (CGSize)sizeThatFits:(CGSize)size {
    size = [super sizeThatFits:size];
    
    size.width += [self padding].left + [self padding].right;
    size.height += [self padding].top + [self padding].bottom;
    return size;
}

@end
