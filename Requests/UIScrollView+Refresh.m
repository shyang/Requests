//
//  UIScrollView+Refresh.m
//  Requests
//
//  Created by shaohua on 2018/5/18.
//  Copyright © 2018 syang. All rights reserved.
//

#import "UIScrollView+Refresh.h"

@implementation UIScrollView (Refresh)

- (RACSignal *)showHeaderWithCommand:(RACCommand *)command {
    [self.mj_header endRefreshing];
    if (!self.mj_header) {
        self.mj_header = [[MJRefreshNormalHeader alloc] init];
    }
    [self.mj_header setRefreshingBlock:^{
        [command execute:nil];
    }];

    @weakify(self);
    [[command.executing skip:1] subscribeNext:^(id x) {
        @strongify(self);
        if (![x boolValue]) {
            [self.mj_header endRefreshing];
        }
    }];

    return [command.executionSignals concat];
}

- (RACSignal *)showHeaderAndFooterWithCommand:(RACCommand *)command {
    @weakify(command);
    @weakify(self);
    return [[self showHeaderWithCommand:command] scanWithStart:[NSMutableArray array] reduce:^id (id running, id next) {
        @strongify(self);
        NSDictionary *cursor = next[0];
        NSArray *items = next[1];
        int page = [cursor[@"page"] intValue];
        int pages = [cursor[@"pages"] intValue];
        if (page < pages) {
            if (self.mj_footer) {
                [self.mj_footer endRefreshing];
            } else { // 无条件重新创建逻辑上 okay 但 UI 上高度有抖动
                self.mj_footer = [[MJRefreshAutoNormalFooter alloc] init];
            }

            self.mj_footer.refreshingBlock =^{
                @strongify(command);
                [command execute:@{@"page": @(page + 1)}];
            };
        } else {
            [self.mj_footer endRefreshingWithNoMoreData];
        }

        [running addObjectsFromArray:items];
        return running;
    }];
}

@end
