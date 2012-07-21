//
//  DBGroupListController.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/20/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "DBGroupListController.h"
#import "DBGroupTableViewCell.h"
#import "DBFetchedResultsController.h"
#import "FBGroup.h"
#import "DBRequest.h"

@implementation DBGroupListController {
    DBFetchedResultsController *resultsController;
}

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        [self setTitle:@"DiscussionBook"];
        resultsController = [[DBFetchedResultsController alloc] init];
        [resultsController setCellReuseIdentifier:[DBGroupTableViewCell reuseIdentifier]];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FBGroup"];
        [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        [resultsController setFetchRequest:fetchRequest];
        
        // start loading the groups
        DBRequest *request = [[DBRequest alloc] initWithResponseObjectType:[FBGroup class]];
        [request setRoute:@"me/groups"];
        [request setResponseObjectsKeyPath:@"data"];
        [request setFailureBlock:^(NSError *error) {
            NSLog(@"failed with error: %@", error);
        }];
        [request setCompletionBlock:^{
            NSLog(@"completed!");
        }];
        [request execute];
    }
    return self;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;
    [resultsController setFetchContext:_managedObjectContext];
}

- (void)viewDidLoad {
    [[self tableView] setDelegate:self];
    UINib *nib = [UINib nibWithNibName:@"DBGroupTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:[DBGroupTableViewCell reuseIdentifier]];
    
    [resultsController setTableView:[self tableView]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"tapped: %@", indexPath);
}

@end
