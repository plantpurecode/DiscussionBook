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
    // use an ordered set for fast lookup
    NSOrderedSet *_currentObjects;
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
    [_tableView reloadData];
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interestingStuffHappened:) name:NSManagedObjectContextDidSaveNotification object:_fetchContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interestingStuffHappened:) name:NSManagedObjectContextObjectsDidChangeNotification object:_fetchContext];
        
        [self _performFetch];
    }
}

- (void)setFetchRequest:(NSFetchRequest *)fetchRequest {
    _fetchRequest = fetchRequest;
    
    [self _removeAllObjects];
    [self _performFetch];
}

- (void)setCellReuseIdentifier:(NSString *)cellReuseIdentifier {
    _cellReuseIdentifier = cellReuseIdentifier;
    
    [self _removeAllObjects];
    [self _performFetch];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [_currentObjects objectAtIndex:[indexPath row]];
}

#pragma mark - Watching for Changes

- (void)interestingStuffHappened:(NSNotification *)note {
    NSDictionary *userInfo = [note userInfo];
    
    BOOL needsUpdate = NO;
    
    NSMutableSet *objects = [NSMutableSet set];
    
    NSSet *deleted = [userInfo objectForKey:NSDeletedObjectsKey];
    NSSet *updated = [userInfo objectForKey:NSUpdatedObjectsKey];
    [objects unionSet:deleted];
    [objects unionSet:updated];
    
    for (id object in objects) {
        if ([_currentObjects containsObject:object]) {
            needsUpdate = YES;
            break;
        }
    }
    
    if (needsUpdate == NO) {
        NSSet *inserted = [userInfo objectForKey:NSInsertedObjectsKey];
        [objects removeAllObjects];
        [objects unionSet:updated];
        [objects unionSet:inserted];
        
        NSPredicate *p = [[self fetchRequest] predicate];
        NSEntityDescription *entity = [[self fetchRequest] entity];
        for (id object in objects) {
            if ([[object entity] isEqual:entity] && (p == nil || [p evaluateWithObject:object] == YES)) {
                needsUpdate = YES;
                break;
            }
        }
    }
    
    if (needsUpdate) {
        [self _performFetch];
    }
}

#pragma mark -

- (NSArray *)_indexPathsForCurrentObjects {
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSUInteger i = 0; i < [_currentObjects count]; ++i) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPaths addObject:path];
    }
    return indexPaths;
}

- (NSArray *)_indexPathsForObjects:(NSSet *)objects inCollection:(NSOrderedSet *)collection {
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (id object in objects) {
        NSUInteger index = [collection indexOfObject:object];
        if (index != NSNotFound) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }
    return indexPaths;
}

- (void)_removeAllObjects {
    NSArray *indexPaths = [self _indexPathsForCurrentObjects];
    _currentObjects = nil;
    if ([indexPaths count] > 0) {
        [[self tableView] deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)_performFetch {
    if ([self fetchContext] == nil || [self fetchRequest] == nil) {
        // can't fetch without a context or request
        return;
    }
    
    NSError *fetchError = nil;
    NSArray *results = [[self fetchContext] executeFetchRequest:[self fetchRequest] error:&fetchError];
    if (results == nil) {
        NSLog(@"error fetching: %@", fetchError);
        return;
    }
    
    NSOrderedSet *oldObjects = _currentObjects;
    NSOrderedSet *newObjects = [NSOrderedSet orderedSetWithArray:results];
    
    _currentObjects = newObjects;
    
    if ([_currentObjects count] == 0) {
        NSArray *indexPaths = [self _indexPathsForCurrentObjects];
        [[self tableView] insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        // we already have objects
        
        // delete things that are in the old set but not in the new set
        NSMutableSet *objectsToDelete = [NSMutableSet setWithSet:[oldObjects set]];
        [objectsToDelete minusSet:[newObjects set]];
        
        // insert things that are in the new set but not in the old set
        NSMutableSet *objectsToInsert = [NSMutableSet setWithSet:[newObjects set]];
        [objectsToInsert minusSet:[oldObjects set]];
        
        // maybe move things that are in both sets
        NSMutableSet *objectsToMove = [NSMutableSet setWithSet:[newObjects set]];
        [objectsToMove intersectSet:[oldObjects set]];
        
        [[self tableView] beginUpdates];
        
        NSMutableArray *indexPathsToDelete = [NSMutableArray array];
        for (id object in objectsToDelete) {
            NSInteger index = [oldObjects indexOfObject:object];
            NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
            [indexPathsToDelete addObject:path];
        }
        [[self tableView] deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
        
        
        NSMutableArray *indexPathsToInsert = [NSMutableArray array];
        for (id object in objectsToInsert) {
            NSInteger index = [newObjects indexOfObject:object];
            NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
            [indexPathsToInsert addObject:path];
        }
        [[self tableView] insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationAutomatic];
        
        
        for (id object in objectsToMove) {
            NSInteger oldIndex = [oldObjects indexOfObject:object];
            NSInteger newIndex = [newObjects indexOfObject:object];
            if (oldIndex != newIndex) {
                NSIndexPath *oldPath = [NSIndexPath indexPathForRow:oldIndex inSection:0];
                NSIndexPath *newPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
                [[self tableView] moveRowAtIndexPath:oldPath toIndexPath:newPath];
            }
        }
        
        [[self tableView] endUpdates];
        
    }
}

@end
