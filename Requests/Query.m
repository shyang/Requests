//
//  Query.m
//  Requests
//
//  Created by shaohua on 2018/5/10.
//  Copyright © 2018 syang. All rights reserved.
//

#import <objc/runtime.h>

#import "Query.h"

typedef NS_ENUM(NSInteger, HttpMethod) {
    GET,
    POST,
};

@interface Query ()

@property (nonatomic) HttpMethod method;
@property (nonatomic) NSString *urlPath;

@property (nonatomic) NSMutableDictionary *parameters;
@property (nonatomic) NSMutableDictionary *headers;

@property (nonatomic) id jsonBody;
@property (nonatomic) void (^multipartBody)(id<AFMultipartFormData>);

@end

@implementation Query

- (instancetype)init {
    if (self = [super init]) {
        _parameters = [NSMutableDictionary new];
        _headers = [NSMutableDictionary new];
    }
    return self;
}

- (void (^)(NSString *, NSDictionary *))get {
    return ^(NSString *urlPath, NSDictionary *parameters) {
        self.urlPath = urlPath;
        self.method = GET;
        [self.parameters addEntriesFromDictionary:parameters];
    };
}

- (void (^)(NSString *, NSDictionary *))post {
    return ^(NSString *urlPath, NSDictionary *parameters) {
        self.urlPath = urlPath;
        self.method = POST;
        [self.parameters addEntriesFromDictionary:parameters];
    };
}

- (void (^)(NSString *, id))postJson {
    return ^(NSString *urlPath, id json) {
        self.urlPath = urlPath;
        self.method = POST;
        self.jsonBody = json;
    };
}

- (void (^)(NSString *, NSDictionary *, void (^)(id<AFMultipartFormData>)))postMultipart {
    return ^(NSString *urlPath, NSDictionary *parameters, void (^block)(id<AFMultipartFormData>)) {
        self.urlPath = urlPath;
        self.method = POST;
        [self.parameters addEntriesFromDictionary:parameters];
        self.multipartBody = block;
    };
}

+ (instancetype)build:(void (^)(Query *))builder {
    id q = [self new];
    builder(q);
    return q;
}

static AFHTTPSessionManager *gManager;
+ (AFHTTPSessionManager *)manager {
    return gManager;
}

+ (void)setManager:(AFHTTPSessionManager *)manager {
    gManager = manager;
}

- (RACSignal *)send:(AFHTTPSessionManager *)manager {
    if (!manager) {
        manager = gManager ?: [AFHTTPSessionManager manager];
    }

    if (_jsonBody) {
        NSCAssert([NSJSONSerialization isValidJSONObject:_jsonBody], @"NSArray or NSDictionary!");
        NSCAssert(_multipartBody == nil, @"WTF");
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
    } else {
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }

    [_headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];

    RACSignal *fetch = nil;
    if (_method == GET) {
        fetch = [manager GET:_urlPath parameters:_parameters];
    } else if (_method == POST) {
        if (_multipartBody) {
            fetch = [manager POST:_urlPath parameters:_parameters constructingBodyWithBlock:_multipartBody];
        } else if (_jsonBody) {
            fetch = [manager POST:_urlPath parameters:_jsonBody];
        } else {
            fetch = [manager POST:_urlPath parameters:_parameters];
        }
    } else {
        NSAssert(NO, @"WTF");
    }

    return fetch;
}

- (RACSignal *)send {
    return [self send:nil];
}

@end
