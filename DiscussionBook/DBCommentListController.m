//
//  DBCommentListController.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/22/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "DBCommentListController.h"
#import "FBGroupThread+DiscussionBook.h"
#import "FBPost+DiscussionBook.h"
#import "DBFetchedResultsController.h"
#import "DBCommentTableViewCell.h"
#import "UITableViewCell+DiscussionBook.h"
#import "DBRequest.h"

@interface DBCommentListController ()

@property (weak) UIActivityIndicatorView *indicatorView;

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator startAnimating];
    _indicatorView = indicator;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBPost *post = [_resultsController objectAtIndexPath:indexPath];
    
#warning WHAT GOES HERE?
    __block CGFloat h = 44;
    if ([post hasComputedHeightForWidth:42]) {
        h = [post computedHeightForWidth:42];
    }
    return h;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(DBCommentTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    FBPost *object = [_resultsController objectAtIndexPath:indexPath];
    CGFloat width = 0;
    if ([object hasComputedHeightForWidth:width] == NO) {
        [object requestComputedHeightForWidth:width inFont:nil handler:^(CGFloat height) {
            NSIndexPath *path = [_resultsController indexPathForObject:object];
            [tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
    }
}

#pragma mark - Private

- (void)fetchComments {
    [_commentsRequest cancel];
    
    _commentsRequest = [_thread requestComments:^(NSArray *comments) {
        [_indicatorView stopAnimating];
        [_indicatorView removeFromSuperview];
    }];
}

@end
