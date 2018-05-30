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

typedef NS_ENUM(NSInteger, HttpMethod) {
    GET,
    POST,
    PUT,
    DELETE,
};

typedef NS_ENUM(NSInteger, ResponseType) {
    JSON, // id: NSDictionary or NSArray
    IMAGE, // UIImage
    RAW, // NSData
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
@property (nonatomic, readonly) void (^multipartBody)(void (^)(id<AFMultipartFormData> formData));
@property (nonatomic) id jsonBody;

@property (nonatomic) ResponseType responseType; // default: JSON
@property (nonatomic) AFHTTPSessionManager *manager; // default: [AFHTTPSessionManager manager]

// store only
@property (nonatomic) Class modelClass;
@property (nonatomic) NSString *listKey;

#pragma mark - The Use Part 使用对象
- (RACSignal *)send;

@end
