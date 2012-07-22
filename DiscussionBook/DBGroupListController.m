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
#import "DBThreadListController.h"
#import "FBGroup+DiscussionBook.h"
#import "DBRequest.h"

@implementation DBGroupListController {
    DBFetchedResultsController *resultsController;
    DBRequest *_groupsRequest;
}

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        [self setTitle:@"DiscussionBook"];
        resultsController = [[DBFetchedResultsController alloc] init];
        [resultsController setCellReuseIdentifier:[DBGroupTableViewCell reuseIdentifier]];
    }
    return self;
}

- (void)requestUserGroups {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FBGroup"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    [resultsController setFetchRequest:fetchRequest];
    
    // start loading the groups
    [_groupsRequest cancel]; //Cancel if already started.

    _groupsRequest = [[DBRequest alloc] initWithResponseObjectType:[FBGroup class]];
    [_groupsRequest setRoute:@"me/groups"];
    [_groupsRequest execute];
}

- (void)removeUserGroups {
    [resultsController setFetchRequest:nil];
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
    FBGroup *group = [resultsController objectAtIndexPath:indexPath];
    DBThreadListController *threadController = [[DBThreadListController alloc] initWithGroup:group];
    [self.navigationController pushViewController:threadController animated:YES];
}

@end
