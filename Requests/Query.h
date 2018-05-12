//
//  NNRequest.h
//  NeoNework
//
//  Created by shaohua on 2018/5/10.
//  Copyright © 2018 syang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <AFNetworking/AFNetworking.h>

@interface Query : NSObject

+ (instancetype)GET:(NSString *)urlPath;
+ (instancetype)POST:(NSString *)urlPath;
+ (instancetype)PUT:(NSString *)urlPath;
+ (instancetype)DELETE:(NSString *)urlPath;

// 批量 headers
- (Query *)headers:(NSDictionary *)headers;
// 单个 header
- (Query *)header:(NSString *)key value:(NSString *)value;

// 批量 parameters
- (Query *)parameters:(NSDictionary *)parameters;
// 单个 parameter
- (Query *)parameter:(NSString *)key value:(id)value; // application/x-www-form-urlencoded

// 设置 body: 这几者互斥
// application/json
- (Query *)jsonBody:(id)body;

// application/octet-stream
- (Query *)rawBody:(NSData *)body;

// multipart/form-data 必须 POST
- (Query *)multipartBody:(void (^)(id<AFMultipartFormData> formData))block;

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

// 共享的 adapter，对 response 进行处理
@property (class, nonatomic) RACSignal *(^adapter)(RACSignal *input);

// 共享的 session manager
@property (class, nonatomic) AFHTTPSessionManager *manager;

@end
