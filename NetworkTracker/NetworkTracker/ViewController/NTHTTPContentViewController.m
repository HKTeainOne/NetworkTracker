//
//  NTHTTPContentViewController.m
//  NetworkTracker
//
//  Created by LiQiu Yu on 16/2/17.
//  Copyright © 2016年 LiQiu Yu. All rights reserved.
//

#import "NTHTTPContentViewController.h"

@interface NTHTTPContentViewController () {
    UITextView *_textView;
}

@end

@implementation NTHTTPContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    _textView = [[UITextView alloc] initWithFrame:self.view.frame];
    _textView.text = _contentString;
    [self.view addSubview:_textView];
    
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
