//
//  DBFetchedResultsController.h
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBFetchedResultsController : NSObject <UITableViewDataSource>

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSManagedObjectContext *fetchContext;
@property (nonatomic, retain) NSFetchRequest *fetchRequest;
@property (nonatomic, copy) NSString *cellReuseIdentifier;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;

@end
