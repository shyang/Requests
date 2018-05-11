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



    [NNRequest setAdapter:^id(id response) {
        return response;
    }];

    [NNRequest setHTTPSessionManager:[[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://0.0.0.0:8000"]]];

    [[[[[[NNRequest GET:@"/foo.json"]
         addHeader:@"foo" value:@"bar"]
        addRawBody:nil]
       addFile:nil mime:nil data:nil]
      send] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    }];

}


@end
