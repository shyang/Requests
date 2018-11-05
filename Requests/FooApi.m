//
//  FooApi.m
//  Requests
//
//  Created by shaohua on 11/5/18.
//  Copyright © 2018 syang. All rights reserved.
//

#import "FooApi.h"

@implementation FooApi

- (instancetype)init {
    if (self = [super init]) {
        self.urlPath = @"http://httpbin.org/status/{userId}";
    }
    return self;
}

@end
