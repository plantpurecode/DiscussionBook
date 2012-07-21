//
//  DBRequest.h
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/21/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBRequest.h"

@interface DBRequest : NSOperation

@property (nonatomic, strong) Class responseObjectType;

@property (nonatomic, copy) NSString *route, *method, *responseObjectsKeyPath;
@property (nonatomic, copy) NSDictionary *parameters;

@property (nonatomic, copy) dispatch_block_t successBlock;
@property (nonatomic, copy) void(^failureBlock)(NSError *error);

@end
