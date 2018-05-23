//
//  ViewController.m
//  Requests
//
//  Created by shaohua on 2018/5/11.
//  Copyright © 2018 syang. All rights reserved.
//

#import "ViewController.h"
#import "SLQuery.h"
#import "CountriesViewController.h"
#import "Country.h"
#import "AFHTTPSessionManager+RACSignal.h"

@interface ViewController ()

@property (nonatomic) NSArray *items;

@end

@implementation ViewController

- (void)dealloc {
    NSLog(@"dealloc %@", self);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _items = @[@"401 Basic Auth",
               @"GET ?query-string",
               @"POST multipart/form-data",
               @"POST application/json",
               @"POST application/x-www-form-urlencoded",
               @"PUT application/json",
               @"DELETE ?query-string",
               @"Parse by Mantle",
               @"Pull to refresh",
               ];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.text = _items[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    if (indexPath.row == 0) {
        /*
         basic auth 会触发 URLSession:task:didReceiveChallenge:completionHandler:
         AFN 会再发起一次重复网络请求
         https://forums.developer.apple.com/thread/39293
         */
        [[manager GET:@"http://httpbin.org/basic-auth/demo/demo" config:nil] subscribeNext:^(id x) {
            NSLog(@"ok: %@", [x first]);
        } error:^(NSError * _Nullable error) {
            NSLog(@"err: %@", error);
        }];
    } else if (indexPath.row == 1) {
        [[manager GET:@"http://httpbin.org/get" config:^(Query *q) {
            [q.parameters addEntriesFromDictionary:@{@"1": @"bb", @"2": @"dd"}];
        }] subscribeNext:^(id x) {
            NSLog(@"ok: %@", [x first]);
        } error:^(NSError *error) {
            NSLog(@"err: %@", error);
        }];
    } else if (indexPath.row == 2) {
        [[manager POST:@"http://httpbin.org/post" config:^(Query *q) {
            [q.parameters addEntriesFromDictionary:@{@"3": @"bb", @"4": @"dd"}];
            q.multipartBody(^(id<AFMultipartFormData> formData) {
                NSURL *url = [[NSBundle mainBundle] URLForResource:@"Info" withExtension:@"plist"];
                NSData *d = [NSData dataWithContentsOfURL:url];
                [formData appendPartWithFormData:d name:@"m3"];
            });
        }] subscribeNext:^(id x) {
            NSLog(@"ok: %@", [x first]);
        } error:^(NSError *error) {
            NSLog(@"err: %@", error);
        }];
    } else if (indexPath.row == 3) {
        [[manager POST:@"http://httpbin.org/post" config:^(Query *q) {
            q.jsonBody = @{@"5": @"bb", @"6": @"dd"};
        }] subscribeNext:^(id x) {
            NSLog(@"ok: %@", [x first]);
        } error:^(NSError *error) {
            NSLog(@"err: %@", error);
        }];
    } else if (indexPath.row == 4) {
        [[manager POST:@"http://httpbin.org/post" config:^(Query *q) {
            [q.parameters addEntriesFromDictionary:@{@"7": @"bb", @"8": @"dd"}];
        }] subscribeNext:^(id x) {
            NSLog(@"ok: %@", [x first]);
        } error:^(NSError *error) {
            NSLog(@"err: %@", error);
        }];
    } else if (indexPath.row == 5) {
        [[manager PUT:@"http://httpbin.org/put" config:^(Query *q) {
            q.jsonBody = @{@"9": @"bb", @"10": @"dd"};
        }] subscribeNext:^(id x) {
            NSLog(@"ok: %@", [x first]);
        } error:^(NSError *error) {
            NSLog(@"err: %@", error);
        }];
    } else if (indexPath.row == 6) {
        RACSignal *a = [manager DELETE:@"http://httpbin.org/delete" config:^(Query *q) {
            [q.parameters addEntriesFromDictionary:@{@"11": @"bb", @"12": @"dd"}];
        }];

        [a subscribeNext:^(id x) {
            NSLog(@"ok: %@", [x first]);
        } error:^(NSError *error) {
            NSLog(@"err: %@", error);
        }];
    } else if (indexPath.row == 7) {
        [[Country getAllContries] subscribeNext:^(id x) {
            NSLog(@"ok: %@", x);
        } error:^(NSError *error) {
            NSLog(@"err: %@", error);
        }];
    } else if (indexPath.row == 8) {
        [self.navigationController pushViewController:[CountriesViewController new] animated:YES];
    }
}

@end
