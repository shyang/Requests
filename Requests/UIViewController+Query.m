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
    return [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [[query send] takeUntil:self.rac_willDeallocSignal];
    }];
}

- (RACCommand *)commandWithQueries:(NSArray<Query *> *)queries {
    return [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [[RACSignal zip:[[queries rac_sequence] map:^(Query *value) {
            return [value send];
        }]] takeUntil:self.rac_willDeallocSignal];
    }];
}

@end
