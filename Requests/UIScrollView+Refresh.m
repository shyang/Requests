//
//  UIScrollView+Refresh.m
//  Requests
//
//  Created by shaohua on 2018/5/18.
//  Copyright © 2018 syang. All rights reserved.
//

#import "Query.h"
#import "UIScrollView+Refresh.h"
#import "NSError+AFNetworking.h"

@implementation UIScrollView (Refresh)

// RACCommand 隐藏于实现内部
- (RACTuple *)showHeader:(RACSignal *)input {
    if (!self.mj_header) {
        self.mj_header = [[MJRefreshNormalHeader alloc] init];
    }

    RACSubject *values = [RACSubject subject];
    RACSubject *errors = [RACSubject subject];

    __block Query *query = nil;
    @weakify(self);
    [self.mj_header setRefreshingBlock:^{
        [query.parameters removeObjectForKey:@"page"]; // reset

        @strongify(self);
        [[input takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSObject *x) {
            query = x.query;
            [values sendNext:x];
        } error:^(NSError *error) {
            [errors sendNext:error];

            [self.mj_header endRefreshing];
        } completed:^{
            [self.mj_header endRefreshing];
        }];
    }];

    return RACTuplePack(values, errors);
}

- (void)showHeader:(RACSignal *)input output:(void (^)(RACSignal *, RACSignal *))output {
    RACTuple *tuple = [self showHeader:input];
    output(tuple.first, tuple.second);
}

- (void)showHeaderAndFooter:(RACSignal *)input output:(void (^)(RACSignal *, RACSignal *))output {
    RACTuple *tuple = [self showHeader:input];
    RACSubject *values = tuple.first;
    RACSubject *errors = tuple.second;

    @weakify(self);
    RACSignal *reduced = [values scanWithStart:[NSMutableArray array] reduce:^id (NSMutableArray *running, NSArray *next) {
        @strongify(self);
        NSArray *items = next;
        Query *query = next.query;
        NSDictionary *cursor = query.responseObject[0];
        int page = [cursor[@"page"] intValue];
        int pages = [cursor[@"pages"] intValue];
        if (page < pages) {
            if (self.mj_footer) {
                [self.mj_footer endRefreshing];
            } else { // 无条件重新创建逻辑上 okay 但 UI 上高度有抖动
                self.mj_footer = [[MJRefreshAutoNormalFooter alloc] init];
            }

            self.mj_footer.refreshingBlock =^{
                @strongify(self);
                query.parameters[@"page"] = @(page + 1);
                [[input takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
                    [values sendNext:x];
                } error:^(NSError *error) {
                    [errors sendNext:error];
                } completed:^{
                    @strongify(self);
                    [self.mj_header endRefreshing];
                }];
            };
        } else {
            [self.mj_footer endRefreshingWithNoMoreData];
        }

        if (query.parameters[@"page"]) {
            [running addObjectsFromArray:items];
            return running;
        }
        return next;
    }];

    output(reduced, errors);
}

@end
