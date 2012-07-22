//
//  DBThreadListController.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "DBThreadListController.h"
#import "DBFetchedResultsController.h"
#import "UITableViewCell+DiscussionBook.h"
#import "DBThreadTableViewCell.h"
#import "FBGroup+DiscussionBook.h"
#import "DBRequest.h"
#import "DBCommentListController.h"
#import "DBCreatePostViewController.h"

@interface DBThreadListController ()

@property (nonatomic, weak) UIActivityIndicatorView *indicatorView;

@end

@implementation DBThreadListController {
    DBRequest *_threadsRequest;
    FBGroup   *_group;
    
    DBFetchedResultsController *_resultsController;
}

- (id)initWithGroup:(FBGroup *)group {
    self = [super initWithStyle:UITableViewStylePlain];
    if(self) {
        _group = group;
        
        [self setTitle:group.name];
        
        _resultsController = [[DBFetchedResultsController alloc] init];
        [_resultsController setCellReuseIdentifier:[DBThreadTableViewCell reuseIdentifier]];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FBGroupThread"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"group = %@", group];
        [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"updatedDate" ascending:NO]]];
        [_resultsController setFetchRequest:fetchRequest];
        [_resultsController setFetchContext:[group managedObjectContext]];

    }
    return self;
}

- (void)dealloc {
    NSLog(@"WHY AM I DESTRUCTING??");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    indicator.center = self.view.center;
    indicator.bounds = (CGRect){CGPointZero, {50, 50}};
    
    [self.view addSubview:indicator];
    [indicator startAnimating];
    _indicatorView = indicator;
    
    [self fetchThreads];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setDelegate:self];
    [[self tableView] setRowHeight:74.0];
    UINib *nib = [UINib nibWithNibName:@"DBThreadTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:[DBThreadTableViewCell reuseIdentifier]];
    
    UIBarButtonItem *createBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                     target:self
                                                                                     action:@selector(composePost)];
    self.navigationItem.rightBarButtonItem = createBarButton;
    
    [_resultsController setTableView:[self tableView]];
}

- (void)composePost {
    NSString *route = [NSString stringWithFormat:@"%@/feed", _group.identifier];
    DBCreatePostViewController *cpvc = [[DBCreatePostViewController alloc] initWithPostType:DBPostTypePost
                                                                             andStreamRoute:route];
    
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:cpvc];
    [self presentModalViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FBGroupThread *thread = [_resultsController objectAtIndexPath:indexPath];
    DBCommentListController *commentsController = [[DBCommentListController alloc] initWithThread:thread];
    [[self navigationController] pushViewController:commentsController animated:YES];
}

#pragma mark - Private

- (void)fetchThreads {
    [_threadsRequest cancel];
    
    _threadsRequest = [_group requestThreads:^(NSArray *threads) {
        [_indicatorView stopAnimating];
        [_indicatorView removeFromSuperview];
    }];
}

@end
