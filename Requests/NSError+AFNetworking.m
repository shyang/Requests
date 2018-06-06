//
//  NSError+AFNetworking.m
//  Requests
//
//  Created by shaohua on 2018/5/24.
//  Copyright © 2018 syang. All rights reserved.
//

#import <objc/runtime.h>
#import <AFNetworking/AFNetworking.h>

#import "NSError+AFNetworking.h"

@implementation NSError (AFNetworking)

static int kQueryKey;

- (Query *)query {
    return objc_getAssociatedObject(self, &kQueryKey);
}

- (void)setQuery:(Query *)query {
    objc_setAssociatedObject(self, &kQueryKey, query, OBJC_ASSOCIATION_RETAIN);
}

- (NSURLResponse *)response {
    return self.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
}

- (NSData *)responseData {
    return self.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
}

@end
