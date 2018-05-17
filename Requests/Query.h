//
//  Query.h
//  Requests
//
//  Created by shaohua on 2018/5/10.
//  Copyright © 2018 syang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <AFNetworking/AFNetworking.h>

#import "AFHTTPSessionManager+RACSignal.h"

@interface Query : NSObject

#pragma mark - The Builder Part 构造对象

// GET 一般无 body
@property (nonatomic, readonly) void (^get)(NSString *urlPath, NSDictionary *parameters);

// Content-Type: application/x-www-form-urlencoded
@property (nonatomic, readonly) void (^post)(NSString *urlPath, NSDictionary *parameters);

// Content-Type: multipart/form-data
@property (nonatomic, readonly) void (^postMultipart)(NSString *urlPath, NSDictionary *parameters, void (^block)(id<AFMultipartFormData> formData));

// Content-Type: application/json
// parameters 必须是 NSArray 或 NSDictionary
@property (nonatomic, readonly) void (^postJson)(NSString *urlPath, id json);

// Content-Type: application/json
// PUT 只支持 JSON body
@property (nonatomic, readonly) void (^put)(NSString *urlPath, id json);

// DELETE 一般无 body
@property (nonatomic, readonly) void (^delete)(NSString *urlPath, NSDictionary *parameters);

@property (nonatomic, readonly) NSMutableDictionary *headers;
@property (nonatomic, readonly) NSMutableDictionary *parameters;

+ (instancetype)build:(void (^)(Query *q))builder;

#pragma mark - The Use Part 使用对象

/*
 * 所以请求都需要加入某些 header，如 User-Agent:
   新建一个 manager， 设置其 sessionConfiguration.HTTPAdditionalHeaders
   Authorization 不应使用全局 Header，有安全漏洞，不如 cookie 自动、安全

 * 某些 API 返回 image:
   新建一个 manager，修改其 responseSerializer

 * 只从 cache 读取:
   新建一个 manager，设置其 sessionConfiguration.requestCachePolicy

 */
- (RACSignal *)send:(AFHTTPSessionManager *)manager;

// 使用缺省的 [AFHTTPSessionManager manager]
- (RACSignal *)send;

@end
