//
//  SLQuery.h
//  Requests
//
//  Created by shaohua on 2018/5/17.
//  Copyright © 2018 syang. All rights reserved.
//

#import <Mantle/Mantle.h>

#import "Query.h"

@interface SLQuery : Query

@property (nonatomic) Class modelClass;

+ (instancetype)build:(void (^)(SLQuery *))builder;

@end
