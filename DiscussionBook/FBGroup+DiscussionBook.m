//
//  FBGroup+DiscussionBook.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "FBGroup+DiscussionBook.h"
#import "FBObject+DiscussionBook.h"
#import "DBRequest.h"
#import "FBGroupThread+DiscussionBook.h"

@implementation FBGroup (DiscussionBook)

+ (NSDictionary *)propertyMapping {
    return @{ @"name" : @"name" };
}

- (DBRequest *)requestThreads:(void(^)(NSArray *threads))handler {
    NSString *route = [NSString stringWithFormat:@"%@/feed", [self identifier]];
    
    DBRequest *request = [[DBRequest alloc] initWithResponseObjectType:[FBGroupThread class]];
    [request setRoute:route];
    if (handler) {
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSManagedObjectContext *c = [self managedObjectContext];
                NSFetchRequest *fr = [[NSFetchRequest alloc] initWithEntityName:@"FBGroupThread"];
                [fr setPredicate:[NSPredicate predicateWithFormat:@"group = %@", self]];
                [fr setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]]];
                
                NSArray *results = [c executeFetchRequest:fr error:nil];
                handler(results);
            });
        }];
    }
    [request execute];
    return request;
}

@end
