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

@property (nonatomic, readonly) void (^get)(NSString *urlPath, NSDictionary *parameters);

// Content-Type: application/x-www-form-urlencoded
@property (nonatomic, readonly) void (^post)(NSString *urlPath, NSDictionary *parameters);

// Content-Type: multipart/form-data
@property (nonatomic, readonly) void (^postMultipart)(NSString *urlPath, NSDictionary *parameters, void (^block)(id<AFMultipartFormData> formData));

// Content-Type: application/json
// parameters 必须是 NSArray 或 NSDictionary
@property (nonatomic, readonly) void (^postJson)(NSString *urlPath, id json);

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

// 使用共享的 session manager
- (RACSignal *)send;

#pragma mark - Global Configuration 全局的配置

// 共享的 session manager
@property (class, nonatomic) AFHTTPSessionManager *manager;

@end
