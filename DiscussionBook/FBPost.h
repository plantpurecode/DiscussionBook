//
//  FBPost.h
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FBObject.h"

@class FBUser;

@interface FBPost : FBObject

@property (nonatomic, retain) NSNumber *likes;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSDate * updatedDate;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) FBUser *fromUser;
@property (nonatomic, retain) NSSet *renderings;

@end
