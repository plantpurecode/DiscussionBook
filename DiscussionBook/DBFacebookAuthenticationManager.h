//
//  DBFacebookAuthenticationManager.h
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBFacebookAuthenticationManager : NSObject

@property (nonatomic, getter = isAuthenticated) BOOL authenticated;

+ (id)sharedManager;

- (void)authenticateWithBlock:(void(^)(BOOL success))block;

- (void)handleOpenURL:(NSURL *)url;

@end
