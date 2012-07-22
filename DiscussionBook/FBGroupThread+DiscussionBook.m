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

@end
