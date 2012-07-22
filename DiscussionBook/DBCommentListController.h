//
//  DBCommentListController.h
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/22/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FBGroupThread;

@interface DBCommentListController : UITableViewController

- (id)initWithThread:(FBGroupThread *)thread;

@end
