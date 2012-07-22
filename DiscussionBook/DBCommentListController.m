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
#import "DBCreatePostViewController.h"

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
        NSEntityDescription *comment = [NSEntityDescription entityForName:@"FBComment" inManagedObjectContext:[thread managedObjectContext]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@ OR (entity = %@ AND thread = %@)", [thread identifier], comment, _thread];
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
    [self setTitle:@"Comments"];
    
    [[self tableView] setDelegate:self];
    [[self tableView] setRowHeight:COMMENT_EMPTY_HEIGHT];
    UINib *nib = [UINib nibWithNibName:@"DBCommentTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:[DBCommentTableViewCell reuseIdentifier]];
    
    UIBarButtonItem *createBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                     target:self
                                                                                     action:@selector(composeComment)];
    self.navigationItem.rightBarButtonItem = createBarButton;
    
    [_resultsController setTableView:[self tableView]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator startAnimating];
    _indicatorView = indicator;
    
    [self fetchComments];
}

- (void)composeComment {
    NSString *route = [NSString stringWithFormat:@"%@/comments", _thread.identifier];
    DBCreatePostViewController *cpvc = [[DBCreatePostViewController alloc] initWithPostType:DBPostTypeComment
                                                                             andStreamRoute:route];
    
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:cpvc];
    [self presentModalViewController:controller animated:YES];    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBPost *post = [_resultsController objectAtIndexPath:indexPath];
    
    CGFloat width = [DBCommentTableViewCell commentWidthForCellWidth:[tableView bounds].size.width];
    CGFloat h = COMMENT_EMPTY_HEIGHT;
    if ([post hasComputedHeightForWidth:width]) {
        h = [post computedHeightForWidth:width];
        h = [DBCommentTableViewCell cellHeightForCommentHeight:h];
    }
    return h;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(DBCommentTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    FBPost *object = [_resultsController objectAtIndexPath:indexPath];
    CGFloat width = [DBCommentTableViewCell commentWidthForCellWidth:[tableView bounds].size.width];
    if ([object hasComputedHeightForWidth:width] == NO) {
        [object requestComputedHeightForWidth:width inFont:COMMENT_FONT handler:^(CGFloat height) {
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
