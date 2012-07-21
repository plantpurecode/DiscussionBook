//
//  DBRequest.h
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBRequest.h"

typedef enum {
    DBRequestMethodGET = 0,
    DBRequestMethodPOST,
    DBRequestMethodDELETE,
    DBRequestMethodPUT,
    DBRequestMethodHEAD
} DBRequestMethod;

@interface DBRequest : NSOperation

- (id)initWithResponseObjectType:(Class)responseObjectType;
@property (nonatomic, readonly) Class responseObjectType;

@property (nonatomic, copy) NSString *route;
@property (nonatomic) DBRequestMethod method;
@property (nonatomic, copy) NSString *responseObjectsKeyPath;
@property (nonatomic, copy) NSDictionary *parameters;

@property (nonatomic, copy) void(^failureBlock)(NSError *error);

- (void)execute;

@end
