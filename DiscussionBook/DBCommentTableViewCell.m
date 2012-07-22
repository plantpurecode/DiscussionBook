//
//  DBCommentTableViewCell.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/22/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "DBCommentTableViewCell.h"
#import "FBComment.h"
#import "FBPost+DiscussionBook.h"
#import "FBUser+DiscussionBook.h"

static NSDateFormatter *CommentDateFormatter() {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setDoesRelativeDateFormatting:YES];
    });
    return formatter;
}

static NSDateFormatter *CommentTimeFormatter() {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    });
    return formatter;
}

@implementation DBCommentTableViewCell

- (void)setRepresentedObject:(id)object {
    _representedObject = object;
    [_userImageActivityIndicator setHidden:YES];
    
    FBUser *user = [_representedObject fromUser];
    [_userName setText:[user name]];
    
    NSNumber *likes = [_representedObject likes];
    NSString *localizedLikes = [NSNumberFormatter localizedStringFromNumber:likes numberStyle:NSNumberFormatterDecimalStyle];
    NSString *likesString = [NSString stringWithFormat:@"%@👍", localizedLikes];
    [_likesLabel setText:likesString];
    
    NSDate *postedDate = [_representedObject creationDate];
    NSString *postedDay = [CommentDateFormatter() stringFromDate:postedDate];
    NSString *postedTime = [CommentTimeFormatter() stringFromDate:postedDate];
    NSString *posted = [NSString stringWithFormat:@"%@ at %@", postedDay, postedTime];
    [_dateLabel setText:posted];
    
    [_messageLabel setFont:COMMENT_FONT];
    if (NO/*[_representedObject hasComputedHeightForWidth:<#(CGFloat)#>]*/) {
        
    } else {
        [_messageLabel setText:@"Loading..."];
    }
}

@end
