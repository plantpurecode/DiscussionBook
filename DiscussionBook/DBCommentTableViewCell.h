//
//  DBCommentTableViewCell.h
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/22/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define COMMENT_EMPTY_HEIGHT 71.0
#define COMMENT_FONT [UIFont systemFontOfSize:15.0]

@interface DBCommentTableViewCell : UITableViewCell

@property (nonatomic, strong) id representedObject;

@property (weak) IBOutlet UIImageView *userImageView;
@property (weak) IBOutlet UIActivityIndicatorView *userImageActivityIndicator;
@property (weak) IBOutlet UILabel *userName;

@property (weak) IBOutlet UILabel *likesLabel;
@property (weak) IBOutlet UILabel *dateLabel;
@property (weak) IBOutlet UILabel *messageLabel;

@end
