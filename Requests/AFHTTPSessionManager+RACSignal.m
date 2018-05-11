//
//  AFHTTPSessionManager+RACSignal.m
//  DRLender
//
//  Created by shaohua on 3/9/16.
//  Copyright © 2016 syang. All rights reserved.
//

#import "AFHTTPSessionManager+RACSignal.h"

@implementation AFHTTPSessionManager (RACSignal)

- (RACSignal *)GET:(NSString *)path parameters:(id)parameters {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *task = [self GET:path parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            [subscriber sendNext:RACTuplePack(responseObject, task.response)];
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:error];
        }];
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}

- (RACSignal *)POST:(NSString *)path parameters:(id)parameters {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *task = [self POST:path parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            [subscriber sendNext:RACTuplePack(responseObject, task.response)];
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:error];
        }];
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}

- (RACSignal *)POST:(NSString *)path parameters:(id)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *task = [self POST:path parameters:parameters constructingBodyWithBlock:block progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            [subscriber sendNext:RACTuplePack(responseObject, task.response)];
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:error];
        }];
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}

- (RACSignal *)PUT:(NSString *)path parameters:(id)parameters {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *task = [self PUT:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            [subscriber sendNext:RACTuplePack(responseObject, task.response)];
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:error];
        }];
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}

- (RACSignal *)DELETE:(NSString *)path parameters:(id)parameters {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *task = [self DELETE:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            [subscriber sendNext:RACTuplePack(responseObject, task.response)];
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:error];
        }];
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}

- (RACSignal *)HEAD:(NSString *)path parameters:(id)parameters {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *task = [self HEAD:path parameters:parameters success:^(NSURLSessionDataTask *task) {
            [subscriber sendNext:RACTuplePack(nil, task.response)];
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:error];
        }];
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}

@end
