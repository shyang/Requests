//
//  Query.m
//  Requests
//
//  Created by shaohua on 2018/5/10.
//  Copyright © 2018 syang. All rights reserved.
//

#import "Query.h"
#import "NSError+AFNetworking.h"
#import "AFHTTPSessionManager+RACSignal.h"

@interface Query ()

@property (nonatomic) NSMutableDictionary *parameters;
@property (nonatomic) NSMutableDictionary *headers;

@end

@implementation Query

- (instancetype)init {
    if (self = [super init]) {
        _method = HttpMethodGet;
        _parameters = [NSMutableDictionary new];
        _headers = [NSMutableDictionary new];
        _responseType = ResponseTypeJSON;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"dealloc %@", self);
}

- (RACSignal *)send {
    // RACSignal body 包含的操作越多，其被 re-subscribe 时，重复执行的操作也越多
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        AFHTTPSessionManager *manager = self.manager ?: [AFHTTPSessionManager manager];

        // 潜在 bug 风险：serializer 类型不匹配时被自动修正，会丢失之前的配置！
        // 故若对 serializer 有定制，请生成并使用多个 manager！

        // 注意 isKindOfClass: 与 isMemberOfClass: 的区别

        // Request Part
        if (self.jsonBody) {
            NSAssert([NSJSONSerialization isValidJSONObject:self.jsonBody], @"must be NSArray or NSDictionary!");
            NSAssert(self.multipartBody == nil, @"不应设置 multipart");
            NSAssert(self.parameters.count == 0, @"无视此处参数！");

            if (![manager.requestSerializer isKindOfClass:[AFJSONRequestSerializer class]]) {
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
            }
        } else {
            if (![manager.requestSerializer isMemberOfClass:[AFHTTPRequestSerializer class]]) {
                manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            }
        }

        // Response Part
        switch (self.responseType) {
        case ResponseTypeJSON:
            if (![manager.responseSerializer isKindOfClass:[AFJSONResponseSerializer class]]) {
                AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
                serializer.removesKeysWithNullValues = YES;
                manager.responseSerializer = serializer;
            }
            break;
        case ResponseTypeImage:
            if (![manager.responseSerializer isKindOfClass:[AFImageResponseSerializer class]]) {
                manager.responseSerializer = [AFImageResponseSerializer serializer];
            }
            break;
        case ResponseTypeRaw:
            if (![manager.responseSerializer isMemberOfClass:[AFHTTPResponseSerializer class]]) {
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            }
        }

        // Headers
        [self.headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];

        void (^ok)(NSURLSessionDataTask *, id) = ^(NSURLSessionDataTask *task, NSObject *responseObject) {
            if (manager.transformResponse) {
                self.responseObject = manager.transformResponse(self, responseObject);
            } else {
                self.responseObject = responseObject;
            }
            self.response = task.response;

            [subscriber sendNext:self];
            [subscriber sendCompleted];
        };
        void (^err)(NSURLSessionDataTask *, NSError *) = ^(NSURLSessionDataTask *task, NSError *error) {
            error.query = self;
            [subscriber sendError:error];
        };

        NSURLSessionDataTask *task = nil;
        switch (self.method) {
            case HttpMethodGet:
                task = [manager GET:self.urlPath parameters:self.parameters progress:nil success:ok failure:err];
                break;
            case HttpMethodPost:
                if (self.multipartBody) {
                    task = [manager POST:self.urlPath parameters:self.parameters constructingBodyWithBlock:self.multipartBody progress:nil success:ok failure:err];
                } else if (self.jsonBody) {
                    task = [manager POST:self.urlPath parameters:self.jsonBody progress:nil success:ok failure:err];
                } else {
                    task = [manager POST:self.urlPath parameters:self.parameters progress:nil success:ok failure:err];
                }
                break;
            case HttpMethodPut:
                task = [manager PUT:self.urlPath parameters:self.jsonBody success:ok failure:err];
                break;
            case HttpMethodDelete:
                task = [manager DELETE:self.urlPath parameters:self.parameters success:ok failure:err];
                break;
        }

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}

@end
