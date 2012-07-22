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
    [_commentCountLabel setPadding:UIEdgeInsetsMake(1, 3, 1, 3)];
    [_commentCountLabel setBackgroundColor:[UIColor grayColor]];
    [_commentCountLabel setTextColor:[UIColor whiteColor]];
    [_commentCountLabel setHighlightedTextColor:[UIColor grayColor]];
    [[_commentCountLabel layer] setCornerRadius:6];
    [_commentCountLabel sizeToFit];
    
    _titleLabel.text   = [[representedObject fromUser] name];
    _dateLabel.text    = @"Blah"; //TODO: utilize date formatter here
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
    
    countFrame.origin.x = CGRectGetMaxX(dateFrame) - countFrame.size.width;
    countFrame.origin.y = roundf(CGRectGetMidY(messageFrame) - (countFrame.size.height/2));
    
    [_commentCountLabel setFrame:countFrame];
}

@end
