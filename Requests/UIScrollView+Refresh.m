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

- (RACTwoTuple *)showHeader:(RACSignal *)input {
    if (!self.mj_header) {
        self.mj_header = [[MJRefreshNormalHeader alloc] init];
    }

    RACSubject *values = [RACSubject subject];
    RACSubject *errors = [RACSubject subject];

    __block Query *query = nil;
    @weakify(self);
    [self.mj_header setRefreshingBlock:^{
        @strongify(self);

        [query.parameters removeObjectForKey:@"page"]; // reset

        [[input takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSObject *x) {
            query = x.query;
            [values sendNext:x];
        } error:^(NSError *error) {
            @strongify(self);
            [errors sendNext:error];

            [self.mj_header endRefreshing];
        } completed:^{
            @strongify(self);
            [self.mj_header endRefreshing];
        }];
    }];

    return RACTuplePack(values, errors);
}

- (RACTwoTuple *)showHeaderAndFooter:(RACSignal *)input {
    RACTuple *tuple = [self showHeader:input];
    RACSubject *values = tuple.first;
    RACSubject *errors = tuple.second;

    @weakify(self);
    @weakify(input);
    @weakify(values);
    RACSignal *reduced = [values scanWithStart:[NSMutableArray array] reduce:^id (NSMutableArray *running, NSArray *next) {
        @strongify(self);

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
                @strongify(input);
                query.parameters[@"page"] = @(page + 1);
                [[input takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
                    @strongify(values);
                    [values sendNext:x];
                } error:^(NSError *error) {
                    [errors sendNext:error];
                }];
            };
        } else {
            [self.mj_footer endRefreshingWithNoMoreData];
        }

        if (query.parameters[@"page"]) {
            [running addObjectsFromArray:next];
            return running;
        }
        return next;
    }];

    return RACTuplePack(reduced, errors);
}

@end
