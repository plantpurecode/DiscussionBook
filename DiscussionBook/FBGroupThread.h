//
//  FBGroupThread.h
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FBPost.h"

@class FBGroup;

@interface FBGroupThread : FBPost

@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) FBGroup *group;
@end

@interface FBGroupThread (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(NSManagedObject *)value;
- (void)removeCommentsObject:(NSManagedObject *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

@end
