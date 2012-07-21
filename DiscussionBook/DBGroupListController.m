//
//  DBGroupListController.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/20/12.
//  Copyright (c) 2012 Doximity. All rights reserved.
//

#import "DBGroupListController.h"

@implementation DBGroupListController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        [self setTitle:@"DiscussionBook"];
    }
    return self;
}

- (void)viewDidLoad {
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(pulledToRefresh:) forControlEvents:UIControlEventValueChanged];
    
    [self setRefreshControl:refresh];
}

- (void)pulledToRefresh:(UIRefreshControl *)sender {
    NSLog(@"pulled!");
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [sender endRefreshing];
    });
}

@end
