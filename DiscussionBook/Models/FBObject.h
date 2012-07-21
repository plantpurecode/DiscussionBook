//
//  FBObject.h
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/20/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FBObject : NSManagedObject

@property (nonatomic, retain) NSString * identifier;

@end
