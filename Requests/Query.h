//
//  Query.h
//  Requests
//
//  Created by shaohua on 2018/5/10.
//  Copyright © 2018 syang. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>

// Query 是一个 value object，封装了一个 network request 的所有输入 & 原始的输出

typedef NS_ENUM(NSInteger, HttpMethod) {
    HttpMethodGet,
    HttpMethodPost,
    HttpMethodPut,
    HttpMethodDelete,
};

/*
 一、GET POST PUT DELETE 可与 Content-Type 任意组合，但实际做了如下限制：

 1. GET DELETE 只支持 parameters，编码在 URL 之中，不允许 jsonBody 或 multipartBody

 2. PUT 只支持 jsonBody，不允许 multipartBody 或 parameters

 3. POST 支持：
    * jsonBody (application/json)
    * parameters (application/x-www-form-urlencoded)
    * parameters + multipartBody (multipart/form-data)

 总结：jsonBody、parameters、multipartBody 互斥，除了 POST multipart 下后两者可共存

 二、输入格式
 * jsonBody
 manager.requestSerializer = [AFJSONRequestSerializer serializer];

 * parameters and/or multipartBody
 manager.requestSerializer = [AFHTTPRequestSerializer serializer];

 三、输出格式
 * responseObject: NSDictionary 或 NSArray
 manager.responseSerializer = [AFJSONResponseSerializer serializer];

 * responseObject: UIImage
 manager.responseSerializer = [AFImageResponseSerializer serializer];

 * responseObject: NSData
 manager.responseSerializer = [AFHTTPResponseSerializer serializer];

 总结：若对 serializer 有定制，请生成并使用多个 manager！它们创建后应 immutable！
 */
@interface Query : NSObject

#pragma mark - The Builder Part 构造对象

@property (nonatomic) HttpMethod method;
@property (nonatomic) NSString *baseURL; // 优先级高于 manager.baseURL
@property (nonatomic) NSString *urlPath;

@property (nonatomic, readonly) NSMutableDictionary *headers; // default: {}
@property (nonatomic, readonly) NSMutableDictionary *parameters; // default: {}
@property (nonatomic) void (^multipartBody)(id<AFMultipartFormData> formData);
@property (nonatomic) id jsonBody; // NSArray or NSDictionary

@property (nonatomic) AFHTTPSessionManager *manager; // default: [AFHTTPSessionManager manager]

// store only, 在 manager.{interceptor,transformResponse} 中自行解析
@property (nonatomic) Class modelClass;
@property (nonatomic) NSString *listKey;

#pragma mark - The Use Part 使用对象
- (RACSignal *)send;

#pragma mark - The Output (上一次) subscribe 后的结果
@property (nonatomic) NSDate *responseDate; // 获得结果的时间
@property (nonatomic, readonly) id responseObject;
@property (nonatomic, readonly) NSURLResponse *response;

@end
