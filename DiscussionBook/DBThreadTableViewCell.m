//
//  DBThreadTableViewCell.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "DBThreadTableViewCell.h"
#import "FBGroupThread.h"
#import "FBUser.h"
#import "DBPaddedLabel.h"

UIKIT_STATIC_INLINE NSDateFormatter *DBRelativeDateFormatter() {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setDoesRelativeDateFormatting:YES];
    });
    
    return formatter;
}

UIKIT_STATIC_INLINE NSDateFormatter *DBTimeFormatter() {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    });
    
    return formatter;
}

UIKIT_STATIC_INLINE BOOL dateIsToday(NSDate *date) {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSUInteger flags = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    NSDateComponents *components = [calendar components:flags
                                               fromDate:date];
    NSDateComponents *nowComponents = [calendar components:flags
                                                  fromDate:[NSDate date]];
    
    return [components isEqual:nowComponents];
}

@interface DBThreadTableViewCell()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

//Multiline
@property (nonatomic, weak) IBOutlet UILabel *detailsLabel;
@property (nonatomic, weak) IBOutlet DBPaddedLabel *commentCountLabel;

@end

@implementation DBThreadTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        [_commentCountLabel setBackgroundColor:[UIColor whiteColor]];
    } else {
        [_commentCountLabel setBackgroundColor:[UIColor grayColor]];
    }

    // Configure the view for the selected state
}

- (void)setRepresentedObject:(FBGroupThread *)representedObject {
    NSUInteger count = representedObject.comments.count;
    [_commentCountLabel setHidden:count == 0];
    
    if(count) {
        NSString *number = [NSNumberFormatter localizedStringFromNumber:@(count) numberStyle:NSNumberFormatterDecimalStyle];
        [_commentCountLabel setText:number];
        [_commentCountLabel setPadding:UIEdgeInsetsMake(1, 3, 1, 3)];
        [_commentCountLabel setBackgroundColor:[UIColor grayColor]];
        [_commentCountLabel setTextColor:[UIColor whiteColor]];
        [_commentCountLabel setHighlightedTextColor:[UIColor grayColor]];
        [[_commentCountLabel layer] setCornerRadius:4];
        [_commentCountLabel sizeToFit];
    }
    
    _titleLabel.text   = [[representedObject fromUser] name];
    
    NSDate *updatedDate  = [representedObject updatedDate];
    NSDateFormatter *formatter = (dateIsToday(updatedDate)) ? DBTimeFormatter() : DBRelativeDateFormatter();
    
    _dateLabel.text    = [formatter stringFromDate:updatedDate];
    [_dateLabel sizeToFit];
    
    _detailsLabel.text = [representedObject message];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        [_commentCountLabel setBackgroundColor:[UIColor whiteColor]];
        [_commentCountLabel setTextColor:[UIColor clearColor]];
    } else {
        [_commentCountLabel setBackgroundColor:[UIColor grayColor]];
        [_commentCountLabel setTextColor:[UIColor whiteColor]];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect countFrame = [_commentCountLabel frame];
    
    CGRect dateFrame = [_dateLabel frame];
    CGRect messageFrame = [_detailsLabel frame];
    
    countFrame.origin.x = self.bounds.size.width - countFrame.size.width - 10;
    countFrame.origin.y = roundf(CGRectGetMidY(messageFrame) - (countFrame.size.height/2));
    
    [_commentCountLabel setFrame:countFrame];
    
    dateFrame.origin.x = self.bounds.size.width - dateFrame.size.width - 10;
    [_dateLabel setFrame:dateFrame];
}

@end
