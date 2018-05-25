//
//  Country.m
//  Requests
//
//  Created by shaohua on 2018/5/18.
//  Copyright © 2018 syang. All rights reserved.
//

#import "AFHTTPSessionManager+RACSignal.h"
#import "Country.h"

@implementation Country

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [NSDictionary mtl_identityPropertyMapWithModel:self];
}

+ (RACSignal *)getAllContries {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    return [manager GET:@"http://api.worldbank.org/v2/countries" config:^(Query *q) {
        [q.parameters addEntriesFromDictionary:@{@"format": @"json", @"per_page": @"100"}];
        q.modelClass = [Country class];
    }];
}

@end
