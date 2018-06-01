//
//  SLQuery.m
//  Requests
//
//  Created by shaohua on 2018/5/17.
//  Copyright © 2018 syang. All rights reserved.
//

#import <Mantle/Mantle.h>

#import "AppConfig.h"
#import "NSError+AFNetworking.h"
#import "Query.h"
#import "AFHTTPSessionManager+RACSignal.h"

@implementation AppConfig

+ (AFHTTPSessionManager *)manager {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];

    RACSignal *retrySignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Auth" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {

        }];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [subscriber sendNext:@{@"Authorization": @"Basic ZGVtbzpkZW1v"}]; // demo:demo
            [subscriber sendCompleted];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }]];
        [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:alert animated:YES completion:^{

        }];
        return nil;
    }];

    manager.interceptor = ^RACSignal *(Query *input, RACSignal *output) {
        // 定制 2: 全局认证
        output = [[output materialize] flattenMap:^(RACEvent *event) {
            // [event.error.userInfo[@"result"] isEqualToString:@"login"]
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)event.error.response;
            if (event.eventType == RACEventTypeError && response.statusCode == 401) {
                return [retrySignal flattenMap:^RACSignal *(id value) {
                    // 成功登录后，再试一次刚才的请求。
                    if ([value count]) {
                        [input.headers addEntriesFromDictionary:value];
                        return output;
                    }
                    return [RACSignal error:event.error];
                }];
            }
            return [[RACSignal return:event] dematerialize];
        }];

        // 定制 3: 全局解析
        if (input.modelClass) {
            output = [output flattenMap:^RACSignal *(RACTuple *value) {
                NSArray *list = value.first[1];
                NSError *error = nil;
                id objects = [MTLJSONAdapter modelsOfClass:input.modelClass fromJSONArray:list error:&error];
                if (error) {
                    return [RACSignal error:error];
                }
                return [RACSignal return:RACTuplePack(objects, value.second)];
            }];
        }
        return output;
    };

    return manager;
}

@end
