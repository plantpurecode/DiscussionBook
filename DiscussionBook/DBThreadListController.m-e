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

@interface DBThreadListController ()

@property (nonatomic, weak) UIActivityIndicatorView *indicatorView;

@end

@implementation DBThreadListController {
    DBRequest *_threadsRequest;
    FBGroup   *_group;
    
    DBFetchedResultsController *resultsController;
}

@synthesize indicatorView;

- (id)initWithGroup:(FBGroup *)group {
    self = [super initWithStyle:UITableViewStylePlain];
    if(self) {
        _group = group;
        
        [self setTitle:group.name];
        
        resultsController = [[DBFetchedResultsController alloc] init];
        [resultsController setCellReuseIdentifier:[DBThreadTableViewCell reuseIdentifier]];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FBGroupThread"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"group = %@", group];
//        [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        [resultsController setFetchRequest:fetchRequest];

    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    indicator.center = self.view.center;
    indicator.bounds = (CGRect){CGPointZero, {50, 50}};
    
    [self.view addSubview:indicator];
    [indicator startAnimating];
    indicatorView = indicator;
    
    [self fetchThreads];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setDelegate:self];
    UINib *nib = [UINib nibWithNibName:@"DBThreadTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:[DBThreadTableViewCell reuseIdentifier]];
    
    [resultsController setTableView:[self tableView]];
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

#pragma mark - Private

- (void)fetchThreads {
    [_threadsRequest cancel];
    
    _threadsRequest = [_group requestThreads:^(NSArray *threads) {
        [indicatorView stopAnimating];
        [indicatorView removeFromSuperview];
    }];
}

@end
