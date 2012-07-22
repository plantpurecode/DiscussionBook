//
//  DBCreatePostViewController.h
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/22/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DBPostTypePost,
    DBPostTypeComment,
} DBPostType;

@interface DBCreatePostViewController : UIViewController

@property (nonatomic, strong) NSString *streamRoute;
@property (nonatomic) DBPostType postType;

- (id)initWithPostType:(DBPostType)postType andStreamRoute:(NSString *)route;

@end
