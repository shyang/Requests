//
//  AFHTTPSessionManager+RACSignal.m
//  Requests
//
//  Created by shaohua on 2018/5/24.
//  Copyright © 2018 syang. All rights reserved.
//

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
    return [query send];
}

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

@end
