//
//  DBFetchedResultsController.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "DBFetchedResultsController.h"
#import "DBGroupTableViewCell.h" // import is only so that we can have the definition of -setRepresentedObject:

@implementation DBFetchedResultsController {
    NSArray *_currentObjects;
}

- (NSUInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSUInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_currentObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell = [tableView dequeueReusableCellWithIdentifier:[self cellReuseIdentifier] forIndexPath:indexPath];
    
    NSManagedObject *object = [_currentObjects objectAtIndex:[indexPath row]];
    if ([cell respondsToSelector:@selector(setRepresentedObject:)]) {
        [cell setRepresentedObject:object];
    }
    
    return cell;
}

#pragma mark -

- (void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
}

- (void)setFetchContext:(NSManagedObjectContext *)fetchContext {
    NSManagedObjectContext *oldContext = _fetchContext;
    
    if (oldContext != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:oldContext];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:oldContext];
        [self _removeAllObjects];
    }
    
    _fetchContext = fetchContext;
    
    if (_fetchContext != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification object:_fetchContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:_fetchContext];
    }
}

- (void)setFetchRequest:(NSFetchRequest *)fetchRequest {
    _fetchRequest = fetchRequest;
}

- (void)setCellReuseIdentifier:(NSString *)cellReuseIdentifier {
    _cellReuseIdentifier = cellReuseIdentifier;
}

#pragma mark -

- (void)_removeAllObjects {
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSUInteger i = 0; i < [_currentObjects count]; ++i) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPaths addObject:path];
    }
    
    _currentObjects = nil;
    [[self tableView] deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)_insertAllObjects {
    
}

@end
