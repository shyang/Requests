//
//  UIViewController+Query.h
//  Requests
//
//  Created by shaohua on 2018/5/18.
//  Copyright © 2018 syang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveObjC/ReactiveObjC.h>

#import "Query.h"

@interface UIViewController (Query)

- (RACCommand *)commandWithQuery:(Query *)query;
- (RACCommand *)commandWithQueries:(NSArray<Query *> *)query;

@end
