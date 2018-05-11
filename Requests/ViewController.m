//
//  ViewController.m
//  Requests
//
//  Created by shaohua on 2018/5/11.
//  Copyright © 2018 syang. All rights reserved.
//

#import "ViewController.h"
#import "NNRequest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NNRequest.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://0.0.0.0:8000"]];

    [[[[[NNRequest GET:@"/foo.json"]
         header:@"foo" value:@"bar"]
        rawBody:nil]
      send] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    }];

}


@end
