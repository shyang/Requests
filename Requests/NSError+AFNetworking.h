//
//  NSError+AFNetworking.h
//  Requests
//
//  Created by shaohua on 2018/5/24.
//  Copyright © 2018 syang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Query.h"

/*
 去掉 Query，直接返回 RACSignal 的最大意义就是 99% 的情况下都在使用 RACSignal
 故此处只是为了那些 1% 需要访问 Query 的情况

 一次请求的输出为 responseObject | error
 若要尽可能的包含完整信息（如原始的 request、response headers，有助于调试、重试等），若干方案：
 1、保存在它们的公共父类 NSObject 之上：在 interceptor 内做变换时需手工传递，略有不便。其它地方变换无需传递，最终使用者较为方便。
 2、保存在 RACSignal 之上：对 signal 做高级变换时很难手工传递。不支持非一对一的变换如 zip ！
 3、使用 RACSignal<RACTwoTuple<id, Query *> *>，放在 x.second 上返回：最终使用者略有不便，绝大部分时间用 x.first。且 error 仍需扩展。
 4、类似 3，专门定义一个 Result = (id, query) 类，清晰明确一些。但 error 仍需扩展。
 5、类似 4，复用 Query，使其包含最终结果

 此 commit 实现为方案5

 2 与 1、3、4 的本质区别是：它在第一次 subscribe 前就可以修改 input

 */

@interface NSObject (AFNetworking)

@property (nonatomic) Query *afnQuery; // config of the request that generated this object

@end

@interface NSError (AFNetworking)

@property (nonatomic, readonly) NSURLResponse *response;
@property (nonatomic, readonly) NSData *responseData;

@end
