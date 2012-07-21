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

@interface DBRequest() <FBRequestDelegate>

@property (nonatomic, readonly) DBAppDelegate *appDelegate;

@end

@implementation DBRequest {
    FBRequest *_request;
    NSManagedObjectContext *_context;

    id _mergeNotificationObserver;
}

@synthesize successBlock, failureBlock;

@synthesize route, parameters, method;
@synthesize responseObjectsKeyPath, responseObjectType;

- (BOOL)isConcurrent {
    return YES;
}

- (void)cancel {
    [super cancel];
    
    _mergeNotificationObserver = nil;
    [[_request connection] cancel];
}

- (void)main {
    _context = [[NSManagedObjectContext alloc] init];

    NSPersistentStoreCoordinator *psc = [[self appDelegate] persistentStoreCoordinator];
    [_context setPersistentStoreCoordinator:psc];
    
    _request = [FBRequest new];
    _request.httpMethod = [self method];
    _request.url        = [self route];
    _request.params     = [[self parameters] mutableCopy];
    _request.delegate   = self;
    
    [_request connect];    
}

#pragma mark - FBRequestDelegate

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
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

- (void)_invokeSuccessBlock {
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
