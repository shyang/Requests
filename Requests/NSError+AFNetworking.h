//
//  NSError+Shortcut.h
//  Requests
//
//  Created by shaohua on 2018/5/24.
//  Copyright © 2018 syang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Query.h"

/*
 一次请求的输出为 responseObject | error
 若要尽可能的包含完整信息（如原始的 request、response headers，有助于调试、重试等），若干方案：
 1、保存在它们的公共父类 NSObject 之上：做变换时需手工传递，略有不便。
 2、保存在 RACSignal 之上：对 signal 做高级变换时需手工传递，略有不便。不支持非一对一的变换如 zip ！
 3、使用 RACSignal<RACTwoTuple<id, Query *> *>，放在 x.second 上返回：最终使用者略有不便，绝大部分时间用 x.first。且 error 仍需扩展。
 4、类似 3，专门定义一个 Result = (id, query) 类，清晰明确一些。但 error 仍需扩展。

 此 commit 实现为方案3
 */

@interface NSError (AFNetworking)

@property (nonatomic, readonly) NSURLResponse *response;
@property (nonatomic, readonly) NSData *responseData;

@property (nonatomic) Query *query; // the request that generated this signal (promise/future)

@end
