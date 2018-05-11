
//
//  NextViewController.m
//  Requests
//
//  Created by shaohua on 2018/5/11.
//  Copyright © 2018 syang. All rights reserved.
//

#import "NextViewController.h"
#import "NNRequest.h"

@implementation NextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NNRequest.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://0.0.0.0:8000"] sessionConfiguration:configuration];

    RACSignal *retrySignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Auth" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {

        }];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [subscriber sendNext:alert.textFields.firstObject.text];
            [subscriber sendCompleted];
        }]];
        [alert showViewController:self sender:nil];
        return nil;
    }];

    NNRequest.adapter = ^RACSignal *(RACSignal *input) {
        return [[input materialize] flattenMap:^(RACEvent *event) {
            // [event.error.userInfo[@"result"] isEqualToString:@"login"]
            if (event.eventType == RACEventTypeError && event.error.code == 401) {
                return [retrySignal flattenMap:^RACSignal *(id value) {
                    // 成功登录后，再试一次刚才的请求。
                    return value ? input : [RACSignal error:event.error];
                }];
            }
            return [[RACSignal return:event] dematerialize];
        }];
    };

    [[[[[NNRequest GET:@"/foo.json"]
        header:@"foo" value:@"bar"]
       rawBody:nil]
      send] subscribeNext:^(id x) {
        NSLog(@"ok: %@", x);
    } error:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];

}

@end
