//
//  Query.m
//  Requests
//
//  Created by shaohua on 2018/5/10.
//  Copyright © 2018 syang. All rights reserved.
//

#import <objc/runtime.h>

#import "Query.h"

@interface Query ()

@property (nonatomic) HttpMethod method;
@property (nonatomic) NSString *urlPath;

@property (nonatomic) NSMutableDictionary *parameters;
@property (nonatomic) NSMutableDictionary *headers;
@property (nonatomic) void (^block)(id<AFMultipartFormData>);

@end

@implementation Query

- (instancetype)initWithMethod:(HttpMethod)method urlPath:(NSString *)urlPath {
    if (self = [super init]) {
        _method = method;
        _urlPath = urlPath;
        _parameters = [NSMutableDictionary new];
        _headers = [NSMutableDictionary new];
        _responseEncoding = NSUTF8StringEncoding;
        _responseType = JSON;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"dealloc %@", self);
}

static RACSignal *(^_interceptor)(Query *input, RACSignal *output);
+ (RACSignal *(^)(Query *, RACSignal *))interceptor {
    return _interceptor;
}

+ (void)setInterceptor:(RACSignal *(^)(Query *, RACSignal *))interceptor {
    _interceptor = interceptor;
}

- (void (^)(void (^)(id<AFMultipartFormData>)))multipartBody {
    return ^(void (^block)(id<AFMultipartFormData>)) {
        self.block = block;
    };
}

- (RACSignal *)send {
    // RACSignal body 包含的操作越多，其被 re-subscribe 时，重复执行的操作也越多
    RACSignal *output = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        AFHTTPSessionManager *manager = self.manager ?: [AFHTTPSessionManager manager];

        if (self.jsonBody) {
            NSCAssert([NSJSONSerialization isValidJSONObject:self.jsonBody], @"NSArray or NSDictionary!");
            NSCAssert(self.block == nil, @"WTF");
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
        } else {
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        }

        [self.headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];

        void (^ok)(NSURLSessionDataTask *, id) = ^(NSURLSessionDataTask *task, id responseObject) {
            [subscriber sendNext:RACTuplePack(responseObject, task.response, self)];
            [subscriber sendCompleted];
        };
        void (^err)(NSURLSessionDataTask *, NSError *) = ^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:error];
        };

        NSURLSessionDataTask *task = nil;
        switch (self.method) {
            case GET:
                task = [manager GET:self.urlPath parameters:self.parameters progress:nil success:ok failure:err];
                break;
            case POST:
                if (self.block) {
                    task = [manager POST:self.urlPath parameters:self.parameters constructingBodyWithBlock:self.block progress:nil success:ok failure:err];
                } else if (self.jsonBody) {
                    task = [manager POST:self.urlPath parameters:self.jsonBody progress:nil success:ok failure:err];
                } else {
                    task = [manager POST:self.urlPath parameters:self.parameters progress:nil success:ok failure:err];
                }
                break;
            case PUT:
                task = [manager PUT:self.urlPath parameters:self.jsonBody success:ok failure:err];
                break;
            case DELETE:
                task = [manager DELETE:self.urlPath parameters:self.parameters success:ok failure:err];
                break;
        }

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];

    return _interceptor ? _interceptor(self, output) : output;
}

@end
