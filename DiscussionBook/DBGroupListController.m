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
        
        DBRequest *request = [[DBRequest alloc] init];
        [request setRoute:@"me/groups"];
    }
    return self;
}

- (void)viewDidLoad {
    [[self tableView] setDelegate:self];
    UINib *nib = [UINib nibWithNibName:@"DBGroupTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:[DBGroupTableViewCell reuseIdentifier]];
    
    resultsController = [[DBFetchedResultsController alloc] init];
    [resultsController setTableView:[self tableView]];
    [resultsController setCellReuseIdentifier:[DBGroupTableViewCell reuseIdentifier]];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"FBGroup" inManagedObjectContext:[self managedObjectContext]]];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    [resultsController setFetchRequest:fetchRequest];
    [resultsController setFetchContext:[self managedObjectContext]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"tapped: %@", indexPath);
}

@end
