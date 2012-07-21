//
//  FBGroup.h
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/20/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FBObject.h"

@class FBPost;

@interface FBGroup : FBObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSOrderedSet *posts;
@end

@interface FBGroup (CoreDataGeneratedAccessors)

- (void)insertObject:(FBPost *)value inPostsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPostsAtIndex:(NSUInteger)idx;
- (void)insertPosts:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePostsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPostsAtIndex:(NSUInteger)idx withObject:(FBPost *)value;
- (void)replacePostsAtIndexes:(NSIndexSet *)indexes withPosts:(NSArray *)values;
- (void)addPostsObject:(FBPost *)value;
- (void)removePostsObject:(FBPost *)value;
- (void)addPosts:(NSOrderedSet *)values;
- (void)removePosts:(NSOrderedSet *)values;
@end
