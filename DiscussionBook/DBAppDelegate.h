//
//  DBAppDelegate.h
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/20/12.
//  Copyright (c) 2012 Doximity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
