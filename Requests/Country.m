//
//  Country.m
//  Requests
//
//  Created by shaohua on 2018/5/18.
//  Copyright © 2018 syang. All rights reserved.
//

#import "Country.h"

@implementation Country

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [NSDictionary mtl_identityPropertyMapWithModel:self];
}

+ (Query *)getAllContries {
    return [SLQuery build:^(SLQuery *q) {
        q.get(@"http://api.worldbank.org/v2/countries", @{@"format": @"json"});
        q.modelClass = [Country class];
    }];
}

@end
