//
//  FBGroup.h
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FBObject.h"

@class FBGroupThread;

@interface FBGroup : FBObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSOrderedSet *threads;
@end

@interface FBGroup (CoreDataGeneratedAccessors)

- (void)insertObject:(FBGroupThread *)value inThreadsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromThreadsAtIndex:(NSUInteger)idx;
- (void)insertThreads:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeThreadsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInThreadsAtIndex:(NSUInteger)idx withObject:(FBGroupThread *)value;
- (void)replaceThreadsAtIndexes:(NSIndexSet *)indexes withThreads:(NSArray *)values;
- (void)addThreadsObject:(FBGroupThread *)value;
- (void)removeThreadsObject:(FBGroupThread *)value;
- (void)addThreads:(NSOrderedSet *)values;
- (void)removeThreads:(NSOrderedSet *)values;
@end
