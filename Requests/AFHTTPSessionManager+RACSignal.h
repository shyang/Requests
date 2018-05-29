//
//  AFHTTPSessionManager+RACSignal.h
//  Requests
//
//  Created by shaohua on 2018/5/24.
//  Copyright © 2018 syang. All rights reserved.
//

#import <AFNetworking/AFHTTPSessionManager.h>

#import "Query.h"

@interface AFHTTPSessionManager (RACSignal)

// Query 是一个 value object，封装了一个 request 的所有输入
/*
 RACSignal Protocol:

 (responseObject, response, query) completed | error

 */

// 兼容老接口
- (RACSignal *)GET:(NSString *)urlPath parameters:(NSDictionary *)parameters;
- (RACSignal *)POST:(NSString *)urlPath parameters:(NSDictionary *)parameters;
- (RACSignal *)PUT:(NSString *)urlPath parameters:(NSDictionary *)parameters;
- (RACSignal *)DELETE:(NSString *)urlPath parameters:(NSDictionary *)parameters;
- (RACSignal *)GET:(NSString *)urlPath parameters:(NSDictionary *)parameters listKey:(NSString *)listKey modelClass:(Class)modelClass;
- (RACSignal *)POST:(NSString *)urlPath parameters:(NSDictionary *)parameters listKey:(NSString *)listKey modelClass:(Class)modelClass;

// 完整的自定义
- (RACSignal *)GET:(NSString *)urlPath config:(void (^)(Query *q))config;
- (RACSignal *)POST:(NSString *)urlPath config:(void (^)(Query *q))config;
- (RACSignal *)PUT:(NSString *)urlPath config:(void (^)(Query *q))config;
- (RACSignal *)DELETE:(NSString *)urlPath config:(void (^)(Query *q))config;

@property (nonatomic) RACSignal *(^interceptor)(Query *input, RACSignal *output);

@end
