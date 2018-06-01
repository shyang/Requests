//
//  Query.m
//  Requests
//
//  Created by shaohua on 2018/5/10.
//  Copyright © 2018 syang. All rights reserved.
//

#import "Query.h"
#import "NSError+AFNetworking.h"

@interface Query ()

@property (nonatomic) NSMutableDictionary *parameters;
@property (nonatomic) NSMutableDictionary *headers;
@property (nonatomic) void (^block)(id<AFMultipartFormData>);

@end

@implementation Query

- (instancetype)init {
    if (self = [super init]) {
        _method = GET;
        _parameters = [NSMutableDictionary new];
        _headers = [NSMutableDictionary new];
        _responseType = JSON;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"dealloc %@", self);
}

- (void (^)(void (^)(id<AFMultipartFormData>)))multipartBody {
    return ^(void (^block)(id<AFMultipartFormData>)) {
        NSAssert(self.method == POST, @"POST only!");
        self.block = block;
    };
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
            NSAssert(self.block == nil, @"不应设置 multipart");
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
        case JSON:
            if (![manager.responseSerializer isKindOfClass:[AFJSONResponseSerializer class]]) {
                AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
                serializer.removesKeysWithNullValues = YES;
                manager.responseSerializer = serializer;
            }
            break;
        case IMAGE:
            if (![manager.responseSerializer isKindOfClass:[AFImageResponseSerializer class]]) {
                manager.responseSerializer = [AFImageResponseSerializer serializer];
            }
            break;
        case RAW:
            if (![manager.responseSerializer isMemberOfClass:[AFHTTPResponseSerializer class]]) {
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            }
        }

        // Headers
        [self.headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];

        void (^ok)(NSURLSessionDataTask *, id) = ^(NSURLSessionDataTask *task, id responseObject) {
            self.responseObject = responseObject;
            self.response = task.response;
            [subscriber sendNext:RACTuplePack(responseObject, self)];
            [subscriber sendCompleted];
        };
        void (^err)(NSURLSessionDataTask *, NSError *) = ^(NSURLSessionDataTask *task, NSError *error) {
            error.query = self;
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
}

@end
