//
//  DBCommentListController.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/22/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "DBCommentListController.h"
#import "FBGroupThread+DiscussionBook.h"
#import "DBFetchedResultsController.h"
#import "DBCommentTableViewCell.h"
#import "UITableViewCell+DiscussionBook.h"

@interface DBCommentListController ()

@end

@implementation DBCommentListController {
    DBRequest *_commentsRequest;
    FBGroupThread *_thread;
    
    DBFetchedResultsController *_resultsController;
}

- (id)initWithThread:(FBGroupThread *)thread {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _thread = thread;
        
        _resultsController = [[DBFetchedResultsController alloc] init];
        [_resultsController setCellReuseIdentifier:[DBCommentTableViewCell reuseIdentifier]];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FBPost"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@ OR (entityName = 'FBComment' AND thread = %@)", [thread identifier], _thread];
        fetchRequest.predicate = predicate;
        [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]]];
        [_resultsController setFetchRequest:fetchRequest];
        [_resultsController setFetchContext:[thread managedObjectContext]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self tableView] setDelegate:self];
    UINib *nib = [UINib nibWithNibName:@"DBCommentTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:[DBCommentTableViewCell reuseIdentifier]];
    
    [_resultsController setTableView:[self tableView]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBPost *post = [_resultsController objectAtIndexPath:indexPath];
    return 44;
}

@end
