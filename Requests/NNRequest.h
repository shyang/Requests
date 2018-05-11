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

typedef NS_ENUM(NSInteger, NNHttpMethod) {
    GET,
    POST,
};

@interface NNRequest : NSObject

@property (nonatomic, readonly) NNHttpMethod method;
@property (nonatomic, readonly) NSDictionary *parameters;
@property (nonatomic, readonly) NSDictionary *files;
@property (nonatomic, readonly) NSString *urlPath;

+ (instancetype)GET:(NSString *)urlPath;
+ (instancetype)POST:(NSString *)urlPath;

- (NNRequest *)addHeader:(NSString *)key value:(NSString *)value;

// 设置 body: 这几者互斥
- (NNRequest *)addParam:(NSString *)key value:(NSString *)value; // application/x-www-form-urlencoded
- (NNRequest *)addJsonBody:(id)body; // application/json
- (NNRequest *)addRawBody:(NSData *)body; // application/octet-stream
- (NNRequest *)addFile:(NSString *)key mime:(NSString *)mime data:(NSData *)data; // multipart/form-data


// 共享的 response adapter，对 response 进行处理
+ (void)setAdapter:(id (^)(id response))adapter;
// 共享的 session manager
+ (void)setHTTPSessionManager:(AFHTTPSessionManager *)manager;

- (RACSignal *)send;

@end
