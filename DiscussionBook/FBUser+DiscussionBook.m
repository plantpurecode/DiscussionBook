//
//  FBUser+DiscussionBook.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "FBUser+DiscussionBook.h"
#import "FBObject+DiscussionBook.h"
#import "DBRequest.h"

static NSString *FBUserCachePathForUserIcon(NSString *identifier) {
    static NSString *userFolder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *folders = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        userFolder = [folders objectAtIndex:0];
    });
    return [userFolder stringByAppendingPathComponent:identifier];
}

@implementation FBUser (DiscussionBook)

+ (UIImage *)cachedImageForUserWithIdentifier:(NSString *)userID {
    NSString *path = FBUserCachePathForUserIcon(userID);
    NSData *d = [NSData dataWithContentsOfFile:path];
    UIImage *image = nil;
    if (d) {
        image = [[UIImage alloc] initWithData:d];
    }
    return image;
}

+ (void)cacheImage:(UIImage *)image forUserWithIdentifier:(NSString *)userID {
    NSData *data = UIImagePNGRepresentation(image);
    NSString *path = FBUserCachePathForUserIcon(userID);
    [data writeToFile:path atomically:YES];
}

+ (NSDictionary *)propertyMapping {
    return @{
        @"name" : @"name"
    };
}

- (void)mergeDataFromDictionary:(NSDictionary *)dictionary {
    [super mergeDataFromDictionary:dictionary];
    
    id pictureData = [dictionary objectForKey:@"picture"];
    NSString *iconURL = nil;
    if ([pictureData isKindOfClass:[NSDictionary class]]) {
        iconURL = pictureData[@"data"][@"url"];
    }
    [self setIconURL:iconURL];
}

- (void)requestUserImage:(void(^)(UIImage *))handler {
    NSString *identifier = [self identifier];
    
    UIImage *icon = [FBUser cachedImageForUserWithIdentifier:identifier];
    
    if (icon == nil) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *iconURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", identifier];
            NSData *d = [NSData dataWithContentsOfURL:[NSURL URLWithString:iconURL]];
            UIImage *image = [[UIImage alloc] initWithData:d];
            // cache the image
            [FBUser cacheImage:image forUserWithIdentifier:identifier];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(image);
            });
        });
    } else {
        handler(icon);
    }
}

@end
