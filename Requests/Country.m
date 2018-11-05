//
//  Country.m
//  Requests
//
//  Created by shaohua on 2018/5/18.
//  Copyright © 2018 syang. All rights reserved.
//

#import "AFHTTPSessionManager+RACSignal.h"
#import "Country.h"
#import "AppConfig.h"

@implementation Country

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [NSDictionary mtl_identityPropertyMapWithModel:self];
}

+ (RACSignal *)getAllContries {
    Query *q = [Query new];
    q.urlPath = @"http://api.worldbank.org/v2/countries";
    [q.parameters addEntriesFromDictionary:@{@"format": @"json", @"per_page": @"100"}];
    q.modelClass = self;
    q.listKey = @"[1]";
    return [[AppConfig manager] send:q];
}

@end
