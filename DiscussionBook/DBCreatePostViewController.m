//
//  DBCreatePostViewController.m
//  DiscussionBook
//
//  Created by Jacob Relkin on 7/22/12.
//  Copyright (c) 2012 Jacob Relkin. All rights reserved.
//

#import "DBCreatePostViewController.h"
#import "DBRequest.h"

@interface DBCreatePostViewController ()

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation DBCreatePostViewController {
    DBRequest *_request;
}

- (id)initWithPostType:(DBPostType)postType andStreamRoute:(NSString *)route {
    self = [super init];
    if(self) {
        _postType    = postType;
        _streamRoute = route;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *postTypeString = (_postType == DBPostTypeComment) ? @"Comment" : @"Post";
    [self setTitle:[NSString stringWithFormat:@"Create %@", postTypeString]];
    
    UIBarButtonItem *createButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                      target:self
                                                                                      action:@selector(_sendRequest)];
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                      target:self
                                                                                      action:@selector(_cancel)];
    self.navigationItem.leftBarButtonItem  = cancelButtonItem;
    self.navigationItem.rightBarButtonItem = createButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Private

- (void)_cancel {
    [_request cancel];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)_sendRequest {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.view.userInteractionEnabled = NO;
    
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    
    __block id this = self;
    _request = [[DBRequest alloc] initWithResponseObjectType:nil];
    _request.route = [self streamRoute];
    _request.method = DBRequestMethodPOST;
    _request.parameters = @{ @"message" : _textView.text };
    _request.completionBlock = ^{
        [this _cancel];
    };
    [_request execute];
}

@end
