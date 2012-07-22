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

@interface DBThreadTableViewCell()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

//Multiline
@property (nonatomic, weak) IBOutlet UILabel *detailsLabel;

@end

@implementation DBThreadTableViewCell

@synthesize representedObject;
@synthesize titleLabel, dateLabel, detailsLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setRepresentedObject:(FBGroupThread *)representedObject {
    titleLabel.text   = [[representedObject fromUser] name];
    dateLabel.text    = @"Blah"; //TODO: utilize date formatter here
    detailsLabel.text = [representedObject message];
}

@end
