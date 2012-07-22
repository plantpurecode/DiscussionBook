//
//  DBThreadListController.h
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FBGroup;

@interface DBThreadListController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (id)initWithGroup:(FBGroup *)group;

@end
