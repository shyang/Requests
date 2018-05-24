//
//  AFHTTPSessionManager+RACSignal.h
//  Requests
//
//  Created by shaohua on 2018/5/24.
//  Copyright © 2018 syang. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "Query.h"

@interface AFHTTPSessionManager (RACSignal)

// Query 是一个 value object，封装了一个 request 的所有输入、输出
/*
 RACSignal Protocol:

 (responseObject, response, query) completed | error

 */
- (RACSignal *)GET:(NSString *)urlPath config:(void (^)(Query *q))config;
- (RACSignal *)POST:(NSString *)urlPath config:(void (^)(Query *q))config;
- (RACSignal *)PUT:(NSString *)urlPath config:(void (^)(Query *q))config;
- (RACSignal *)DELETE:(NSString *)urlPath config:(void (^)(Query *q))config;

@end
