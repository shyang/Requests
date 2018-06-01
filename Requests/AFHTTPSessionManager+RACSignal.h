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

/*
 RACSignal Protocol:

 (responseObject, query) completed | error

 query.responseObject 原始输出
 query.response       NSURLResponse
 */

// 兼容老接口
- (RACSignal<RACTwoTuple<id, Query *> *> *)GET:(NSString *)urlPath parameters:(NSDictionary *)parameters;
- (RACSignal<RACTwoTuple<id, Query *> *> *)POST:(NSString *)urlPath parameters:(NSDictionary *)parameters;
- (RACSignal<RACTwoTuple<id, Query *> *> *)PUT:(NSString *)urlPath parameters:(NSDictionary *)parameters;
- (RACSignal<RACTwoTuple<id, Query *> *> *)DELETE:(NSString *)urlPath parameters:(NSDictionary *)parameters;
- (RACSignal<RACTwoTuple<id, Query *> *> *)GET:(NSString *)urlPath parameters:(NSDictionary *)parameters listKey:(NSString *)listKey modelClass:(Class)modelClass;
- (RACSignal<RACTwoTuple<id, Query *> *> *)POST:(NSString *)urlPath parameters:(NSDictionary *)parameters listKey:(NSString *)listKey modelClass:(Class)modelClass;
- (RACSignal<RACTwoTuple<id, Query *> *> *)POST:(NSString *)urlPath parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))block;

// 新的统一接口，urlPath 是必须的，所以特别提取了出来
- (RACSignal<RACTwoTuple<id, Query *> *> *)GET:(NSString *)urlPath config:(void (^)(Query *q))config;
- (RACSignal<RACTwoTuple<id, Query *> *> *)POST:(NSString *)urlPath config:(void (^)(Query *q))config;
- (RACSignal<RACTwoTuple<id, Query *> *> *)PUT:(NSString *)urlPath config:(void (^)(Query *q))config;
- (RACSignal<RACTwoTuple<id, Query *> *> *)DELETE:(NSString *)urlPath config:(void (^)(Query *q))config;

// 每个 manager 一个 interceptor，供其发出的所有请求共享
@property (nonatomic) RACSignal *(^interceptor)(Query *input, RACSignal *output);

@end
