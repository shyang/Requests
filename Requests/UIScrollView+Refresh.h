//
//  UIScrollView+Refresh.h
//  Requests
//
//  Created by shaohua on 2018/5/18.
//  Copyright © 2018 syang. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <UIKit/UIKit.h>

@interface UIScrollView (Refresh)

/*
 创建一个 MJRefreshNormalHeader/MJRefreshAutoNormalFooter，
 下拉或上拉刷新后 subscribe input, 其 next 与 error 被分流到两个 signal 中：
 values 或 errors，对它们 subscribe 不会触发 input。
 */

- (void)showHeader:(RACSignal *)inputSignal output:(void (^)(RACSignal *values, RACSignal *errors))output;
- (void)showHeaderAndFooter:(RACSignal *)inputSignal output:(void (^)(RACSignal *values, RACSignal *errors))output;

@end
