//
//  UIScrollView+Refresh.h
//  Requests
//
//  Created by shaohua on 2018/5/18.
//  Copyright © 2018 syang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <MJRefresh/MJRefresh.h>

@interface UIScrollView (Refresh)

/*
 创建一个 MJRefreshNormalHeader，下拉后触发 [command execute:nil]
 */

- (void)showHeader:(RACSignal *)input output:(void (^)(RACSignal *values, RACSignal *errors))output;
- (void)showHeaderAndFooter:(RACSignal *)input output:(void (^)(RACSignal *values, RACSignal *errors))output;

@end
