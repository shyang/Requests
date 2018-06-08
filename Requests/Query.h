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

// Query 是一个 value object，封装了一个 request 的所有输入 & 原始的输出

typedef NS_ENUM(NSInteger, HttpMethod) {
    HttpMethodGet,
    HttpMethodPost,
    HttpMethodPut,
    HttpMethodDelete,
};

typedef NS_ENUM(NSInteger, ResponseType) {
    ResponseTypeJSON, // id: NSDictionary or NSArray
    ResponseTypeImage, // UIImage
    ResponseTypeRaw, // NSData
};

/*
 GET POST PUT DELETE 可与 Content-Type 任意组合，但实际会做限制：

 GET DELETE 只支持 parameters，编码在 URL 之中，不允许 jsonBody 或 multipartBody

 PUT 只支持 jsonBody，不允许 multipartBody 或 parameters

 POST 支持：
 * jsonBody (application/json)
 * parameters (application/x-www-form-urlencoded)
 * parameters + multipartBody (multipart/form-data)

 总结：jsonBody、parameters、multipartBody 互斥，除了 POST multipart 下后两者可共存

 */
@interface Query : NSObject

#pragma mark - The Builder Part 构造对象

@property (nonatomic) HttpMethod method;
@property (nonatomic) NSString *urlPath;

@property (nonatomic, readonly) NSMutableDictionary *headers; // default: {}
@property (nonatomic, readonly) NSMutableDictionary *parameters; // default: {}
@property (nonatomic) void (^multipartBody)(id<AFMultipartFormData> formData);
@property (nonatomic) id jsonBody;

@property (nonatomic) ResponseType responseType; // default: JSON
@property (nonatomic) AFHTTPSessionManager *manager; // default: [AFHTTPSessionManager manager]

// store only
@property (nonatomic) Class modelClass;
@property (nonatomic) NSString *listKey;

#pragma mark - The Use Part 使用对象
- (RACSignal *)send;

#pragma mark - The Output (上一次) subscribe 后的结果
@property (nonatomic) id responseObject;
@property (nonatomic) NSURLResponse *response;

@end
