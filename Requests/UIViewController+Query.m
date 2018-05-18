//
//  UIViewController+Query.m
//  Requests
//
//  Created by shaohua on 2018/5/18.
//  Copyright © 2018 syang. All rights reserved.
//

#import "UIViewController+Query.h"

@implementation UIViewController (Query)

- (RACCommand *)commandWithQuery:(Query *)query {
    @weakify(self);
    return [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [query.parameters addEntriesFromDictionary:input];
        return [[query send] takeUntil:self.rac_willDeallocSignal];
    }];
}

- (RACCommand *)commandWithQueries:(NSArray<Query *> *)queries {
    @weakify(self);
    return [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        return [[RACSignal zip:[[queries rac_sequence] map:^(Query *value) {
            [value.parameters addEntriesFromDictionary:input];
            return [value send];
        }]] takeUntil:self.rac_willDeallocSignal];
    }];
}

@end
