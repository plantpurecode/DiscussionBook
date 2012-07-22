//
//  FBPost+DiscussionBook.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "FBPost+DiscussionBook.h"
#import "FBObject+DiscussionBook.h"
#import "FBUser+DiscussionBook.h"

@implementation FBPost (DiscussionBook)

+ (NSDictionary *)propertyMapping {
    return @{
        @"created_time" : @"creationDate",
        @"updated_time" : @"updatedDate",
        @"message" : @"message"
    };
}

- (id)initWithDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    self = [super initWithDictionary:dictionary inManagedObjectContext:context];
    if (self) {
        NSDictionary *fromData = dictionary[@"from"];
        FBUser *user = [FBUser objectWithDictionary:fromData inContext:context];
        [self setValue:user forKey:@"fromUser"];
    }
    return self;
}

- (NSManagedObject *)renderingForWidth:(CGFloat)width {
    NSFetchRequest *fr = [[NSFetchRequest alloc] initWithEntityName:@"FBPostRendering"];
    [fr setPredicate:[NSPredicate predicateWithFormat:@"post = %@ AND width = %f", self, width]];
    NSArray *results = [[self managedObjectContext] executeFetchRequest:fr error:nil];
    if ([results count] > 0) {
        return [results objectAtIndex:0];
    }
    return nil;
}

- (BOOL)hasComputedHeightForWidth:(CGFloat)width {
    return [self renderingForWidth:width] != nil;
}

- (CGFloat)computedHeightForWidth:(CGFloat)width {
    NSManagedObject *rendering = [self renderingForWidth:width];
    if (rendering == nil) { return 0; }
    NSNumber *height = [rendering valueForKey:@"height"];
    return [height floatValue];
}

- (void)requestComputedHeightForWidth:(CGFloat)width inFont:(UIFont *)font handler:(void(^)(CGFloat height))handler {
    if ([self hasComputedHeightForWidth:width]) {
        if (handler) {
            handler([self computedHeightForWidth:width]);
        }
    } else {
        NSString *message = [self message];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            // compute the height
            CGFloat height = 0;
            
            CGSize size = [message sizeWithFont:font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)];
            height = size.height;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSManagedObject *rendering = [NSEntityDescription insertNewObjectForEntityForName:@"FBPostRendering" inManagedObjectContext:[self managedObjectContext]];
                [rendering setValue:@(width) forKey:@"width"];
                [rendering setValue:@(height) forKey:@"height"];
                [rendering setValue:self forKey:@"post"];
                
                if (handler) {
                    handler(height);
                }
            });
        });
    }
}

@end
