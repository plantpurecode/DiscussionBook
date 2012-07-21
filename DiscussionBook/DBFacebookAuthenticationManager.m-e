//
//  DBFacebookAuthenticationManager.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "DBFacebookAuthenticationManager.h"
#import "FBConnect.h"


static NSString *DBFBApplicationID = @"138133029659393";
static NSString *FBNSUserDefaultsAccessTokenKey = @"FBNSUserDefaultsAccessTokenKey";

@interface DBFacebookAuthenticationManager() <FBSessionDelegate, FBDialogDelegate>
@end

@implementation DBFacebookAuthenticationManager {
    Facebook *_facebookObject;
    
    void(^_queuedSuccessBlock)(BOOL);
}

+ (id)sharedManager {
    static id manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [DBFacebookAuthenticationManager new];
    });
    return manager;
}

- (id)init {
    self = [super init];
    if(self) {
        _facebookObject = [[Facebook alloc] initWithAppId:DBFBApplicationID
                                              andDelegate:self];
        _facebookObject.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:FBNSUserDefaultsAccessTokenKey];
        _facebookObject.expirationDate = [NSDate distantFuture];
    }
    return self;
}

- (BOOL)authenticated {
    return [_facebookObject isSessionValid];
}

- (void)authenticateWithBlock:(void(^)(BOOL success))block {
    _queuedSuccessBlock = block;

    /*
     client_id=YOUR_APP_ID
     &redirect_uri=YOUR_REDIRECT_URL
     &state=YOUR_STATE_VALUE
     &scope=COMMA_SEPARATED_LIST_OF_PERMISSION_NAMES
     */
    
    NSDictionary *parameters = @{
        @"client_id" : DBFBApplicationID,
        @"scope" : @"user_groups"
    };
    
    [_facebookObject dialog:@"oauth"
                  andParams:[parameters mutableCopy]
                andDelegate:self];
}

#pragma mark - FBSessionDelegate

- (void)fbDidLogin {
    NSString *accessToken = [_facebookObject accessToken];
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:FBNSUserDefaultsAccessTokenKey];
}

- (void)fbDidLogout {
    [NSUserDefaults resetStandardUserDefaults];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    //do something here...
}

#pragma mark - FBDialogDelegate

- (void)dialogCompleteWithUrl:(NSURL *)url {
    if(_queuedSuccessBlock)
        _queuedSuccessBlock(YES);
}

- (void)dialogDidNotCompleteWithUrl:(NSURL *)url {
    if(_queuedSuccessBlock)
        _queuedSuccessBlock(NO);
}

@end
