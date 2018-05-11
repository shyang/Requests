//
//  ViewController.m
//  Requests
//
//  Created by shaohua on 2018/5/11.
//  Copyright © 2018 syang. All rights reserved.
//

#import "ViewController.h"
#import "NextViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(onNext)];
}

- (void)onNext {
    [self.navigationController pushViewController:[NextViewController new] animated:YES];
}

@end
