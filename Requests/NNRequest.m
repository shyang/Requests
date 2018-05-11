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

@implementation NNRequest

- (instancetype)initWithMethod:(NNHttpMethod)method urlPath:(NSString *)urlPath {
    if (self = [super init]) {
        _parameters = [NSMutableDictionary new];
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

- (NNRequest *)addFile:(NSString *)key mime:(NSString *)mime data:(NSData *)data {
    return self;
}

- (NNRequest *)addParam:(NSString *)key value:(NSString *)value {
    return self;
}

- (NNRequest *)addRawBody:(NSData *)body {
    return self;
}

- (NNRequest *)addJsonBody:(id)body {
    return self;
}

- (NNRequest *)addHeader:(NSString *)key value:(NSString *)value {
    return self;
}

static id (^gAdapter)(id input);
+ (void)setAdapter:(id (^)(id))adapter {
    gAdapter = adapter;
}

static AFHTTPSessionManager *gManager;
+ (void)setHTTPSessionManager:(AFHTTPSessionManager *)manager {
    gManager = manager;
}

- (RACSignal *)send {
    RACSignal *fetch = nil;
    switch (_method) {
        case GET:
            fetch = [gManager GET:_urlPath parameters:_parameters];
            break;
        case POST:
            fetch = [gManager POST:_urlPath parameters:_parameters];
            break;
        default:
            break;
    }

    if (gAdapter) {
        fetch = gAdapter(fetch);
    }

    return fetch;
}

@end
