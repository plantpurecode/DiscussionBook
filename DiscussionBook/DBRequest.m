//
//  DBRequest.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "DBRequest.h"
#import "DBAppDelegate.h"
#import "FBObject.h"

UIKIT_STATIC_INLINE NSOperationQueue *DBRequestOperationQueue() {
    static NSOperationQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[NSOperationQueue alloc] init];
    });
    return queue;
}

typedef enum {
    DBRequestStateReady,
    DBRequestStateStarted,
    DBRequestStateFinished,
    DBRequestStateCancelled,
} DBRequestState;

static NSString * DBRequestMethods[] = {
    @"GET",
    @"POST",
    @"DELETE",
    @"PUT",
    @"HEAD"
};

@interface DBRequest() <FBRequestDelegate>

@property (nonatomic, readonly) DBAppDelegate *appDelegate;

@end

@implementation DBRequest {
    FBRequest *_request;
    NSManagedObjectContext *_context;
    
    DBRequestState _state;

    id _mergeNotificationObserver;
}

@synthesize successBlock, failureBlock;

@synthesize route, parameters, method;
@synthesize responseObjectsKeyPath, responseObjectType;

- (id)init {
    self = [super init];
    if(self) {
        _state = DBRequestStateReady;
    }
    return self;
}

- (BOOL)isFinished {
    return _state == DBRequestStateFinished;
}

- (BOOL)isCancelled {
    return _state == DBRequestStateCancelled;
}

- (BOOL)isExecuting {
    return _state == DBRequestStateStarted;
}

- (BOOL)isReady {
    return _state == DBRequestStateReady;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)cancel {
    [self _performKVCModificationWithKey:@"isCancelled" block:^{
        _state = DBRequestStateCancelled;
    }];
    
    [super cancel];
    
    _mergeNotificationObserver = nil;
    [[_request connection] cancel];
}

- (void)start {
    [self _performKVCModificationWithKey:@"isStarted" block:^{
        _state = DBRequestStateStarted;
    }];
    
    [super start];
}

- (void)main {
    _context = [[NSManagedObjectContext alloc] init];

    NSPersistentStoreCoordinator *psc = [[self appDelegate] persistentStoreCoordinator];
    [_context setPersistentStoreCoordinator:psc];
    
    _request = [FBRequest new];
    _request.httpMethod = DBRequestMethods[[self method]];
    _request.url        = [self route];
    _request.params     = [[self parameters] mutableCopy];
    _request.delegate   = self;
    
    [_request connect];    
}

- (void)execute {
    [DBRequestOperationQueue() addOperation:self];
}

#pragma mark - FBRequestDelegate

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    [self _performKVCModificationWithKey:@"isFinished" block:^{
        _state = DBRequestStateFinished;
    }];
    
    if(failureBlock) {
        failureBlock(error);
    }
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    if(responseObjectsKeyPath) {
        result = [result valueForKeyPath:responseObjectsKeyPath];
    }

    if([result isKindOfClass:[NSArray class]]) {
        for(id obj in result) {
            [self _createModelObjectWithDictionary:obj];
        }
    } else {
        [self _createModelObjectWithDictionary:result];
    }
    
    [self _invokeSuccessBlock];
}

#pragma mark Private

- (DBAppDelegate *)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}

- (void)_performKVCModificationWithKey:(NSString *)key block:(dispatch_block_t)block {
    [self willChangeValueForKey:key];
    if(block) {
        block();
    }
    [self didChangeValueForKey:key];
}

- (void)_invokeSuccessBlock {
    [self _performKVCModificationWithKey:@"isFinished"
                                   block:^{
       void (^notificationBlock)(NSNotification *) = ^(NSNotification *note) {
           _mergeNotificationObserver = nil;
           
           NSManagedObjectContext *mainContext = [[self appDelegate] managedObjectContext];
           [mainContext mergeChangesFromContextDidSaveNotification:note];
       };
       
       _mergeNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                                                      object:nil
                                                                                       queue:[NSOperationQueue mainQueue]
                                                                                  usingBlock:notificationBlock];
       
       NSError *error = nil;
       [_context save:&error];
       
       if(successBlock) {
           dispatch_async(dispatch_get_main_queue(), successBlock);
       }
                                       
       _state = DBRequestStateFinished;
    }];
}

- (void)_createModelObjectWithDictionary:(NSDictionary *)dictionary {
    Class cls = [self responseObjectType];
    if(![cls isSubclassOfClass:[NSManagedObject class]]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Response object type must be a NSManagedObject"];
    }
    
    (void)[[cls alloc] initWithDictionary:dictionary inManagedObjectContext:_context];
}

@end
