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
    return [self send:query];
}

- (RACSignal *)send:(Query *)query {
    query.manager = self;
    return self.interceptor ? self.interceptor([query send]) : [query send];
}

#pragma mark - extra properties
static void *kInterceptorKey;
- (RACSignal *(^)(RACSignal *))interceptor {
    return objc_getAssociatedObject(self, &kInterceptorKey);
}

- (void)setInterceptor:(RACSignal *(^)(RACSignal *))interceptor {
    objc_setAssociatedObject(self, &kInterceptorKey, interceptor, OBJC_ASSOCIATION_COPY);
}

static void *kTransformResponseKey;
- (id (^)(Query *, id))transformResponse {
    return objc_getAssociatedObject(self, &kTransformResponseKey);
}

- (void)setTransformResponse:(id (^)(Query *, id))transformResponse {
    objc_setAssociatedObject(self, &kTransformResponseKey, transformResponse, OBJC_ASSOCIATION_COPY);
}

static void *kTransformRequestKey;
- (void (^)(Query *))transformRequest {
    return objc_getAssociatedObject(self, &kTransformRequestKey);
}

- (void)setTransformRequest:(void (^)(Query *))transformRequest {
    objc_setAssociatedObject(self, &kTransformRequestKey, transformRequest, OBJC_ASSOCIATION_COPY);
}

#pragma mark -
- (RACSignal *)GET:(NSString *)urlPath config:(void (^)(Query *))config {
    return [self requst:HttpMethodGet urlPath:urlPath config:config];
}

- (RACSignal *)POST:(NSString *)urlPath config:(void (^)(Query *))config {
    return [self requst:HttpMethodPost urlPath:urlPath config:config];
}

- (RACSignal *)PUT:(NSString *)urlPath config:(void (^)(Query *))config {
    return [self requst:HttpMethodPut urlPath:urlPath config:config];
}

- (RACSignal *)DELETE:(NSString *)urlPath config:(void (^)(Query *))config {
    return [self requst:HttpMethodDelete urlPath:urlPath config:config];
}

#pragma mark - Legacy
- (RACSignal *)requst:(HttpMethod)method urlPath:(NSString *)urlPath parameters:(NSDictionary *)parameters {
    return [self requst:method urlPath:urlPath config:^(Query *q) {
        [q.parameters addEntriesFromDictionary:parameters];
    }];
}

- (RACSignal *)GET:(NSString *)urlPath parameters:(NSDictionary *)parameters {
    return [self requst:HttpMethodGet urlPath:urlPath parameters:parameters];
}

- (RACSignal *)POST:(NSString *)urlPath parameters:(NSDictionary *)parameters {
    return [self requst:HttpMethodPost urlPath:urlPath parameters:parameters];
}

- (RACSignal *)PUT:(NSString *)urlPath parameters:(NSDictionary *)parameters {
    return [self requst:HttpMethodPut urlPath:urlPath parameters:parameters];
}

- (RACSignal *)DELETE:(NSString *)urlPath parameters:(NSDictionary *)parameters {
    return [self requst:HttpMethodDelete urlPath:urlPath parameters:parameters];
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
    return [self requst:HttpMethodGet urlPath:urlPath parameters:parameters listKey:listKey modelClass:modelClass];
}

- (RACSignal *)GET:(NSString *)urlPath parameters:(NSDictionary *)parameters listKey:(NSString *)listKey {
    return [self requst:HttpMethodGet urlPath:urlPath parameters:parameters listKey:listKey modelClass:nil];
}

- (RACSignal *)POST:(NSString *)urlPath parameters:(NSDictionary *)parameters listKey:(NSString *)listKey modelClass:(Class)modelClass {
    return [self requst:HttpMethodPost urlPath:urlPath parameters:parameters listKey:listKey modelClass:modelClass];
}

- (RACSignal *)POST:(NSString *)urlPath parameters:(NSDictionary *)parameters listKey:(NSString *)listKey {
    return [self requst:HttpMethodPost urlPath:urlPath parameters:parameters listKey:listKey modelClass:nil];
}

- (RACSignal *)POST:(NSString *)urlPath parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block {
    return [self requst:HttpMethodPost urlPath:urlPath config:^(Query *q) {
        [q.parameters addEntriesFromDictionary:parameters];
        q.multipartBody = block;
    }];
}

- (id)copyWithZone:(NSZone *)zone {
    AFHTTPSessionManager *HTTPClient = [[[self class] allocWithZone:zone] initWithBaseURL:self.baseURL sessionConfiguration:self.session.configuration];

    HTTPClient.requestSerializer = [self.requestSerializer copyWithZone:zone];
    HTTPClient.responseSerializer = [self.responseSerializer copyWithZone:zone];
    HTTPClient.securityPolicy = [self.securityPolicy copyWithZone:zone];

    // copy associated properties
    HTTPClient.interceptor = self.interceptor;
    HTTPClient.transformResponse = self.transformResponse;
    HTTPClient.transformRequest = self.transformRequest;
    return HTTPClient;
}

@end
