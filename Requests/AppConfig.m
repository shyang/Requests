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
    static AFHTTPSessionManager *manager;
    if (manager) {
        return manager;
    }
    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    conf.requestCachePolicy = NSURLRequestReloadRevalidatingCacheData;
    manager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil sessionConfiguration:conf];

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

    manager.interceptor = ^RACSignal *(RACSignal *output) {
        return [[[output materialize] flattenMap:^(RACEvent *event) {
            // 全局认证
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)event.error.response;
            if (event.eventType == RACEventTypeError && response.statusCode == 401) {
                return [retrySignal flattenMap:^RACSignal *(id value) {
                    // 成功登录后，再试一次刚才的请求。
                    if ([value count]) {
                        [event.error.query.headers addEntriesFromDictionary:value];
                        return output;
                    }
                    return [RACSignal error:event.error];
                }];
            }
            return [[RACSignal return:event] dematerialize];
        }] flattenMap:^RACSignal *(Query *value) {
            NSArray *x = value.responseObject;
            // 全局解析
            if (value.modelClass) {
                NSArray *cursor = x[0];
                NSArray *items = x[1];

                NSError *error = nil;
                NSArray *objects = [MTLJSONAdapter modelsOfClass:value.modelClass fromJSONArray:items error:&error];
                if (error) {
                    return [RACSignal error:error];
                }
                return [RACSignal return:@[cursor, objects, value]]; // 支持分页需要原始的 Query；注意循环引用
            }
            return [RACSignal return:x]; // 绝大部分调用只关心解析后的结果
        }];
    };

    manager.transformResponse = ^id (Query *query, id responseObject) {
        // 全局拼接
        if (!query.listKey || !query.responseObject) {
            return responseObject;
        }

        id last = query.responseObject;
        NSDictionary *cursor = responseObject[0];
        if ([last[0][@"page"] intValue] + 1 == [cursor[@"page"] intValue]) {
            NSMutableArray *concat = [NSMutableArray array];
            [concat addObjectsFromArray:last[1]];
            [concat addObjectsFromArray:responseObject[1]];
            return @[cursor, concat];
        }
        return responseObject;
    };

    return manager;
}

@end
