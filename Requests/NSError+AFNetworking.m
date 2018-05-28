//
//  NSError+Shortcut.m
//  Requests
//
//  Created by shaohua on 2018/5/24.
//  Copyright © 2018 syang. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "NSError+AFNetworking.h"

@implementation NSError (AFNetworking)

- (NSURLResponse *)response {
    return self.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
}

- (NSData *)responseData {
    return self.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
}

@end
