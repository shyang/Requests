//
//  NNRequest.m
//  NeoNework
//
//  Created by shaohua on 2018/5/10.
//  Copyright © 2018 syang. All rights reserved.
//

#import <objc/runtime.h>

#import "AFHTTPSessionManager+RACSignal.h"
#import "NNRequest.h"

@interface NNRequest ()

@property (nonatomic) NNHttpMethod method;
@property (nonatomic) NSString *urlPath;

@property (nonatomic) NSMutableDictionary *parameters;
@property (nonatomic) NSMutableDictionary *headers;
@property (nonatomic) NSMutableDictionary *files;

@property (nonatomic) NSData *body;
@property (nonatomic) void (^bodyBlock)(id<AFMultipartFormData>);

@end

@implementation NNRequest

- (instancetype)initWithMethod:(NNHttpMethod)method urlPath:(NSString *)urlPath {
    if (self = [super init]) {
        _parameters = [NSMutableDictionary new];
        _headers = [NSMutableDictionary new];
        _files = [NSMutableDictionary new];
        _method = method;
        _urlPath = urlPath;
    }
    return self;
}

+ (instancetype)GET:(NSString *)urlPath {
    return [[self alloc] initWithMethod:GET urlPath:urlPath];
}

+ (instancetype)POST:(NSString *)urlPath {
    return [[self alloc] initWithMethod:POST urlPath:urlPath];
}

+ (instancetype)PUT:(NSString *)urlPath {
    return [[self alloc] initWithMethod:PUT urlPath:urlPath];
}

+ (instancetype)DELETE:(NSString *)urlPath {
    return [[self alloc] initWithMethod:DELETE urlPath:urlPath];
}

+ (instancetype)HEAD:(NSString *)urlPath {
    return [[self alloc] initWithMethod:HEAD urlPath:urlPath];
}

static RACSignal *(^gAdapter)(RACSignal *input);
+ (RACSignal *(^)(RACSignal *input))adapter {
    return gAdapter;
}

+ (void)setAdapter:(RACSignal *(^)(RACSignal *))adapter {
    gAdapter = adapter;
}

static AFHTTPSessionManager *gManager;
+ (AFHTTPSessionManager *)manager {
    return gManager;
}

+ (void)setManager:(AFHTTPSessionManager *)manager {
    gManager = manager;
}

- (NNRequest *)multipartBody:(void (^)(id<AFMultipartFormData>))block {
    NSAssert([_parameters count] == 0, @"multipart 格式下的参数一律用 AFMultipartFormData 添加");
    NSAssert(_body == nil, @"multipart 格式下不可指定 body");
    _bodyBlock = block;
    return self;
}

- (NNRequest *)parameters:(NSDictionary *)parameters {
    [_parameters addEntriesFromDictionary:parameters];
    return self;
}

- (NNRequest *)parameter:(NSString *)key value:(NSString *)value {
    _parameters[key] = value;
    return self;
}

- (NNRequest *)rawBody:(NSData *)body {
    _body = body;
    return self;
}

- (NNRequest *)jsonBody:(id)body {
    NSError *error = nil;
    _body = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];
    NSAssert(error == nil, @"WTF");
    return self;
}

- (NNRequest *)headers:(NSDictionary *)headers {
    [_headers addEntriesFromDictionary:headers];
    return self;
}

- (NNRequest *)header:(NSString *)key value:(NSString *)value {
    _headers[key] = value;
    return self;
}

- (RACSignal *)send:(AFHTTPSessionManager *)manager {
    RACSignal *fetch = nil;
    if (_bodyBlock) {
        NSAssert(_method == POST, @"WTF");
        fetch = [manager POST:_urlPath parameters:_parameters constructingBodyWithBlock:_bodyBlock];
    } else if (_method == GET) {
        fetch = [manager GET:_urlPath parameters:_parameters];
    } else if (_method == POST) {
        fetch = [manager POST:_urlPath parameters:_parameters];
    } else if (_method == PUT) {
        fetch = [manager PUT:_urlPath parameters:_parameters];
    } else if (_method == DELETE) {
        fetch = [manager DELETE:_urlPath parameters:_parameters];
    } else {
        NSAssert(NO, @"WTF");
    }

    if (gAdapter) {
        fetch = gAdapter(fetch);
    }

    return fetch;
}

- (RACSignal *)send {
    return [self send:gManager];
}

@end
