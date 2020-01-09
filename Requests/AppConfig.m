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
                return [retrySignal flattenMap:^RACSignal *(NSDictionary *value) {
                    // 成功登录后，再试一次刚才的请求。
                    if ([value count]) { // 搜索 demo:demo
                        [event.error.afnQuery.headers addEntriesFromDictionary:value];
                        return output;
                    }
                    return [RACSignal error:event.error];
                }];
            }
            return [[RACSignal return:event] dematerialize];
        }] flattenMap:^RACSignal *(id x) {
            // 全局解析
            Query *query = [x afnQuery];
            if (query.modelClass) {
                // 该后台返回的是数组
                NSArray *cursor = x[0];
                NSArray *items = x[1];

                NSError *error = nil;
                NSArray *objects = [MTLJSONAdapter modelsOfClass:query.modelClass fromJSONArray:items error:&error];
                if (error) {
                    return [RACSignal error:error];
                }
                query.userInfo = cursor; // 支持分页得保留 cursor 信息
                objects.afnQuery = query; // 传递 query 供请求下一页，注意循环引用
                return [RACSignal return:objects]; // 与其它路径一样只输出订阅者关心的数据
            }
            return [RACSignal return:x]; // 绝大部分调用只关心解析后的结果
        }];
    };

    manager.transformResponse = ^id (id responseObject) {
        // 未做变换
        return responseObject;
    };

    return manager;
}

@end
