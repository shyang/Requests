//
//  SLQuery.h
//  Requests
//
//  Created by shaohua on 2018/5/17.
//  Copyright © 2018 syang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

/*
 参考实现

 根据使用的 API，支持
    全局的登录重试
    JSON 转 Native
    分页 API 的合并等

 其它功能如全局的 URL 改写等
 */
@interface AppConfig : NSObject

+ (AFHTTPSessionManager *)manager;

@end
