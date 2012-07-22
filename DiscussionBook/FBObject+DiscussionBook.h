//
//  FBObject+DiscussionBook.h
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "FBObject.h"

@interface FBObject (DiscussionBook)

+ (NSDictionary *)properties;
+ (NSDictionary *)propertyMapping;

+ (id)objectWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context;
- (id)initWithDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context;

@end
