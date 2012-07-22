//
//  FBUser.h
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FBObject.h"

@class FBPost;

@interface FBUser : FBObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * iconURL;
@property (nonatomic, retain) NSSet *posts;
@end

@interface FBUser (CoreDataGeneratedAccessors)

- (void)addPostsObject:(FBPost *)value;
- (void)removePostsObject:(FBPost *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

@end
