//
//  FBGroupThread+DiscussionBook.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "FBGroupThread+DiscussionBook.h"
#import "FBObject+DiscussionBook.h"
#import "FBComment.h"
#import "DBRequest.h"

@implementation FBGroupThread (DiscussionBook)

- (id)initWithDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    self = [super initWithDictionary:dictionary inManagedObjectContext:context];
    if (self) {
        NSArray *comments = dictionary[@"comments"][@"data"];
        
        for (NSDictionary *commentData in comments) {
            FBComment *comment = [FBComment objectWithDictionary:commentData inContext:context];
            [comment setValue:self forKey:@"thread"];
        }
    }
    return self;
}

- (DBRequest *)requestComments:(void(^)(NSArray *comments))handler {
    NSString *route = [NSString stringWithFormat:@"%@", [self identifier]];
    
    DBRequest *request = [[DBRequest alloc] initWithResponseObjectType:[FBComment class]];
    [request setRoute:route];
    
    NSManagedObjectID *groupID = [self objectID];
    [request setInitializationCallback:^(FBObject *object){
        id thread = [[object managedObjectContext] objectWithID:groupID];
        [object setValue:thread forKey:@"thread"];
    }];
    if (handler) {
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSManagedObjectContext *c = [self managedObjectContext];
                NSFetchRequest *fr = [[NSFetchRequest alloc] initWithEntityName:@"FBComment"];
                [fr setPredicate:[NSPredicate predicateWithFormat:@"thread = %@", self]];
                [fr setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]]];
                
                NSArray *results = [c executeFetchRequest:fr error:nil];
                handler(results);
            });
        }];
    }
    [request execute];
    return request;
}

@end
