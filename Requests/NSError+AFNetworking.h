//
//  NSError+Shortcut.h
//  Requests
//
//  Created by shaohua on 2018/5/24.
//  Copyright © 2018 syang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (AFNetworking)

@property (nonatomic, readonly) NSURLResponse *response;
@property (nonatomic, readonly) NSData *responseData;

@end
