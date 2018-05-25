

网络库 2018 改版

### 背景

上次改版引入了 RACSignal (ReactiveCocoa) 来封装异步行为，
接受度良好，但也存在一些问题：

1. 依赖过大

Mantle、MJRefresh、MBProgressHUD 由于实现原因未能做成 optional，

现在还依赖了 SDVersion、DRMUser，这对一个目标较为通用的网络库而言，已经不可接受了。

2. V3 与一些不规范的 API 实现导致解析逻辑较为丑陋

这些 application specific 的逻辑需要挪到应用层

Example 中会提供若干参考实现，用 app 取用

3. RACCommand 一些误用、滥用

隐藏 RACCommand，减少理解负担，减少误用的机会

### 优化

1. 依赖减少 & 升级

只依赖 ReactiveCocoa 的后续版本 ReactiveObjC

2. Query 简单化

Query 原始的设计为 RACSignal Factory，不复杂但毕竟多一层包装

新版将其降级为简单的 value object，即 java 中 POJO。

3. RACSignal 为中心

核心直接以 RACSignal 为基础，subscribe 代表了一次网络调用。

其成功返回一个 tuple: (responseObject, response, query)

responseObject: 默认是从 json 解析过来的 NSDictionary 或 NSArray
    在 query 的一些属性控制下，可能是 UIImage、NSString，或未解析的原始 NSData

response: NSURLResponse 包含可能需要的 statusCode、headers 等信息

query: 发起这个请求的所有信息，mutable。修改它可影响后续的 subscribe

4. 全局 interceptor

Query.interceptor 提供了应用层拦截所有网络请求的机会

通过此，把之前解析（Mantle）、重登录等逻辑移出网络库

5. 下拉刷新，无限滚动

已作为参考实现放入 Example 中，因为 API 的分页逻辑不那么统一，属于 app specific 的一部分

并隐藏了 RACCommand 的使用。


