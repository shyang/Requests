//
//  AFHTTPSessionManager+RACSignal.m
//  Requests
//
//  Created by shaohua on 2018/5/24.
//  Copyright © 2018 syang. All rights reserved.
//

#import <objc/runtime.h>

#import "AFHTTPSessionManager+RACSignal.h"

@implementation AFHTTPSessionManager (RACSignal)

- (RACSignal *)requst:(HttpMethod)method urlPath:(NSString *)urlPath config:(void (^)(Query *))config {
    Query *query = [Query new];
    query.method = method;
    query.urlPath = urlPath;
    if (config) {
        config(query);
    }
    query.manager = self;
    return self.interceptor ? self.interceptor(query, [query send]) : [query send];
}

static void *kInterceptorKey;
- (RACSignal *(^)(Query *, RACSignal *))interceptor {
    return objc_getAssociatedObject(self, &kInterceptorKey);
}

- (void)setInterceptor:(RACSignal *(^)(Query *, RACSignal *))interceptor {
    objc_setAssociatedObject(self, &kInterceptorKey, interceptor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -
- (RACSignal *)GET:(NSString *)urlPath config:(void (^)(Query *))config {
    return [self requst:GET urlPath:urlPath config:config];
}

- (RACSignal *)POST:(NSString *)urlPath config:(void (^)(Query *))config {
    return [self requst:POST urlPath:urlPath config:config];
}

- (RACSignal *)PUT:(NSString *)urlPath config:(void (^)(Query *))config {
    return [self requst:PUT urlPath:urlPath config:config];
}

- (RACSignal *)DELETE:(NSString *)urlPath config:(void (^)(Query *))config {
    return [self requst:DELETE urlPath:urlPath config:config];
}

#pragma mark - Legacy
- (RACSignal *)requst:(HttpMethod)method urlPath:(NSString *)urlPath parameters:(NSDictionary *)parameters {
    return [self requst:method urlPath:urlPath config:^(Query *q) {
        [q.parameters addEntriesFromDictionary:parameters];
    }];
}

- (RACSignal *)GET:(NSString *)urlPath parameters:(NSDictionary *)parameters {
    return [self requst:GET urlPath:urlPath parameters:parameters];
}

- (RACSignal *)POST:(NSString *)urlPath parameters:(NSDictionary *)parameters {
    return [self requst:POST urlPath:urlPath parameters:parameters];
}

- (RACSignal *)PUT:(NSString *)urlPath parameters:(NSDictionary *)parameters {
    return [self requst:PUT urlPath:urlPath parameters:parameters];
}

- (RACSignal *)DELETE:(NSString *)urlPath parameters:(NSDictionary *)parameters {
    return [self requst:DELETE urlPath:urlPath parameters:parameters];
}

#pragma mark - Legacy
- (RACSignal *)requst:(HttpMethod)method urlPath:(NSString *)urlPath parameters:(NSDictionary *)parameters listKey:(NSString *)listKey modelClass:(Class)modelClass {
    return [self requst:method urlPath:urlPath config:^(Query *q) {
        [q.parameters addEntriesFromDictionary:parameters];
        q.listKey = listKey;
        q.modelClass = modelClass;
    }];
}

- (RACSignal *)GET:(NSString *)urlPath parameters:(NSDictionary *)parameters listKey:(NSString *)listKey modelClass:(Class)modelClass {
    return [self requst:GET urlPath:urlPath parameters:parameters listKey:listKey modelClass:modelClass];
}

- (RACSignal *)POST:(NSString *)urlPath parameters:(NSDictionary *)parameters listKey:(NSString *)listKey modelClass:(Class)modelClass {
    return [self requst:POST urlPath:urlPath parameters:parameters listKey:listKey modelClass:modelClass];
}

@end
