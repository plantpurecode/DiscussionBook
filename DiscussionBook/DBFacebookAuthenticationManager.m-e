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
static NSString *FBNSUserDefaultsAccessTokenKey     = @"FBNSUserDefaultsAccessTokenKey";
static NSString *FBNSUserDefaultsExpirationDateKey = @"FBNSUserDefaultsExpirationDateKey";

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
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _facebookObject.accessToken    = [defaults objectForKey:FBNSUserDefaultsAccessTokenKey];
        _facebookObject.expirationDate = [defaults objectForKey:FBNSUserDefaultsExpirationDateKey];
    }
    return self;
}

- (NSString *)accessToken {
    return [_facebookObject accessToken];
}

- (NSDate *)expirationDate {
    return [_facebookObject expirationDate];
}

- (BOOL)isAuthenticated {
    return [_facebookObject isSessionValid];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    return [_facebookObject handleOpenURL:url];
}

- (void)authenticateWithBlock:(void(^)(BOOL success))block {
    _queuedSuccessBlock = block;
    
    if ([self isAuthenticated]) {
        [self dialogCompleteWithUrl:nil];
    } else {
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
}

#pragma mark - FBSessionDelegate

- (void)fbDidLogin {
    NSString *accessToken = [self accessToken];
    NSDate   *expiration  = [self expirationDate];
    
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:FBNSUserDefaultsAccessTokenKey];
    [[NSUserDefaults standardUserDefaults] setObject:expiration  forKey:FBNSUserDefaultsExpirationDateKey];
    
    if(_queuedSuccessBlock)
        _queuedSuccessBlock(YES);
}

- (void)fbDidLogout {
    [NSUserDefaults resetStandardUserDefaults];
}

- (void)fbSessionInvalidated {
    //...
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    //do something here...
    
    if(_queuedSuccessBlock)
        _queuedSuccessBlock(NO);
}

- (void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    [[NSUserDefaults standardUserDefaults] setObject:accessToken  forKey:FBNSUserDefaultsAccessTokenKey];
    [[NSUserDefaults standardUserDefaults] setObject:expiresAt    forKey:FBNSUserDefaultsExpirationDateKey];
}

#pragma mark - FBDialogDelegate

- (void)dialogDidComplete:(FBDialog *)dialog {
    if(_queuedSuccessBlock)
        _queuedSuccessBlock(YES);
}

- (void)dialogDidNotComplete:(FBDialog *)dialog {
    if(_queuedSuccessBlock)
        _queuedSuccessBlock(NO);
}

- (void)dialogCompleteWithUrl:(NSURL *)url {
    if(_queuedSuccessBlock)
        _queuedSuccessBlock(YES);
}

- (void)dialogDidNotCompleteWithUrl:(NSURL *)url {
    if(_queuedSuccessBlock)
        _queuedSuccessBlock(NO);
}

@end
