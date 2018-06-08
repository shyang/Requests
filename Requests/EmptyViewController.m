//
//  EmptyViewController.m
//  Requests
//
//  Created by shaohua on 2018/5/18.
//  Copyright © 2018 syang. All rights reserved.
//

#import "EmptyViewController.h"
#import "ViewController.h"

@interface EmptyViewController ()

@end

@implementation EmptyViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(onNext)];

    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:32 * 1024 * 1024
                                                            diskCapacity:64 * 1024 * 1024
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
}

- (void)onNext {
    [self.navigationController pushViewController:[ViewController new] animated:YES];
}

@end
