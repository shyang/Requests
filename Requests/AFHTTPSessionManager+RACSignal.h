//
//  AFHTTPSessionManager+RACSignal.h
//  DRLender
//
//  Created by shaohua on 3/9/16.
//  Copyright © 2016 syang. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface AFHTTPSessionManager (RACSignal)

- (RACSignal *)GET:(NSString *)path parameters:(id)parameters;
- (RACSignal *)POST:(NSString *)path parameters:(id)parameters;
- (RACSignal *)POST:(NSString *)path parameters:(id)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))block;

@end
