//
//  Query.m
//  Requests
//
//  Created by shaohua on 2018/5/10.
//  Copyright © 2018 syang. All rights reserved.
//

#import <objc/runtime.h>

#import "AFHTTPSessionManager+RACSignal.h"
#import "Query.h"

typedef NS_ENUM(NSInteger, HttpMethod) {
    GET,
    POST,
    PUT,
    DELETE,
};

@interface Query ()

@property (nonatomic) HttpMethod method;
@property (nonatomic) NSString *urlPath;

@property (nonatomic) NSMutableDictionary *parameters;
@property (nonatomic) NSMutableDictionary *headers;

@end

@implementation Query

- (instancetype)init {
    if (self = [super init]) {
        _parameters = [NSMutableDictionary new];
        _headers = [NSMutableDictionary new];
    }
    return self;
}

- (void (^)(NSString *))get {
    return ^(NSString *urlPath) {
        self.urlPath = urlPath;
        self.method = GET;
    };
}

- (void (^)(NSString *))post {
    return ^(NSString *urlPath) {
        self.urlPath = urlPath;
        self.method = POST;
    };
}

- (void (^)(NSString *))put {
    return ^(NSString *urlPath) {
        self.urlPath = urlPath;
        self.method = PUT;
    };
}

- (void (^)(NSString *))delete {
    return ^(NSString *urlPath) {
        self.urlPath = urlPath;
        self.method = DELETE;
    };
}

+ (instancetype)build:(void (^)(Query *))builder {
    Query *q = [Query new];
    builder(q);
    return q;
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

- (RACSignal *)send:(AFHTTPSessionManager *)manager {
    // _body = [NSJSONSerialization dataWithJSONObject:jsonBody options:0 error:&error];

    RACSignal *fetch = nil;
    if (_multipartBody) {
        NSAssert(_method == POST, @"WTF");
        fetch = [manager POST:_urlPath parameters:_parameters constructingBodyWithBlock:_multipartBody];
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
