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

@property (nonatomic, readonly) void (^get)(NSString *urlPath);
@property (nonatomic, readonly) void (^post)(NSString *urlPath);
@property (nonatomic, readonly) void (^put)(NSString *urlPath);
@property (nonatomic, readonly) void (^delete)(NSString *urlPath);

/*
 去除 parameters:(NSDictionary *)parameters 的理由：
 容易写出这样的代码 parameters:@{key: var} 并且对 var 可能 nil 没有保护，潜在的 crash！

 而 parameters[key] = var; 遇到 nil 时是删除该 pair
 */

@property (nonatomic, readonly) NSMutableDictionary *parameters;
@property (nonatomic, readonly) NSMutableDictionary *headers;

// 缺省 body 的格式为 application/x-www-form-urlencoded

// 设置 body 的格式为 application/json
// 可传入 NSArray/NSDictionary/NSString 等可被 JSON Serialize 的对象
@property (nonatomic) id jsonBody;

// 设置 body 的格式为 application/octet-stream
@property (nonatomic) NSData *rawBody;

// 设置 body 的格式为 multipart/form-data 必须 POST
@property (nonatomic) void (^multipartBody)(id<AFMultipartFormData> formData);

+ (instancetype)build:(void (^)(Query *q))builder;

#pragma mark - The Use Part 使用对象

/*
 * 所以请求都需要加入某些 header，如 User-Agent、Authorization:
   新建一个 manager， 设置其 sessionConfiguration.HTTPAdditionalHeaders
 * 某些 API 返回 image:
   新建一个 manager，修改其 responseSerializer
 * 只从 cache 读取:
   新建一个 manager，设置其 sessionConfiguration.requestCachePolicy
 *
 */
- (RACSignal *)send:(AFHTTPSessionManager *)manager;

// 使用共享的 session manager
- (RACSignal *)send;

#pragma mark - Global Configuration 全局的配置
// 共享的 adapter，对 response 进行处理
@property (class, nonatomic) RACSignal *(^adapter)(RACSignal *input);

// 共享的 session manager
@property (class, nonatomic) AFHTTPSessionManager *manager;

@end
