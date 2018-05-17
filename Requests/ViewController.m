//
//  ViewController.m
//  Requests
//
//  Created by shaohua on 2018/5/11.
//  Copyright © 2018 syang. All rights reserved.
//

#import "ViewController.h"
#import "SLQuery.h"
#import "UIViewController+Query.h"
#import "UIScrollView+Refresh.h"
#import "Country.h"

@interface ViewController ()

@property (nonatomic) NSArray *items;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _items = @[@"401 Basic Auth",
               @"GET ?query-string",
               @"POST multipart/form-data",
               @"POST application/json",
               @"POST application/x-www-form-urlencoded",
               @"PUT application/json",
               @"DELETE ?query-string",
               @"Parse by Mantle"
               ];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];

    RACCommand *cmd = [self commandWithQuery:[Query build:^(Query *q) {
        q.get(@"http://api.worldbank.org/v2/topics", @{@"format": @"json", @"per_page": @"10"});
    }]];
    [[self.tableView showHeaderAndFooterWithCommand:cmd] subscribeNext:^(id x) {
        NSLog(@"pull header ok %@", x);
    }];
    [cmd.errors subscribeNext:^(NSError *x) {
        NSLog(@"pull header err %@", x);
    }];
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
    if (indexPath.row == 0) {
        /*
         basic auth 会触发 URLSession:task:didReceiveChallenge:completionHandler:
         AFN 会再发起一次重复网络请求
         https://forums.developer.apple.com/thread/39293
         */
        [[[SLQuery build:^(Query *q) {
            q.get(@"http://httpbin.org/basic-auth/demo/demo", nil);
        }] send] subscribeNext:^(id x) {
            NSLog(@"ok: %@", x);
        } error:^(NSError * _Nullable error) {
            NSLog(@"err: %@", error);
        }];
    } else if (indexPath.row == 1) {
        [[[Query build:^(Query *q) {
            q.get(@"http://httpbin.org/get", @{@"1": @"bb", @"2": @"dd"});
        }] send] subscribeNext:^(id x) {
            NSLog(@"ok: %@", x);
        } error:^(NSError *error) {
            NSLog(@"err: %@", error);
        }];
    } else if (indexPath.row == 2) {
        [[[Query build:^(Query *q) {
            q.postMultipart(@"http://httpbin.org/post", @{@"3": @"bb", @"4": @"dd"}, ^(id<AFMultipartFormData> formData) {
                NSURL *url = [[NSBundle mainBundle] URLForResource:@"Info" withExtension:@"plist"];
                NSData *d = [NSData dataWithContentsOfURL:url];
                [formData appendPartWithFormData:d name:@"m3"];
            });
        }] send] subscribeNext:^(id x) {
            NSLog(@"ok: %@", x);
        } error:^(NSError *error) {
            NSLog(@"err: %@", error);
        }];
    } else if (indexPath.row == 3) {
        [[[Query build:^(Query *q) {
            q.postJson(@"http://httpbin.org/post", @{@"5": @"bb", @"6": @"dd"});
        }] send] subscribeNext:^(id x) {
            NSLog(@"ok: %@", x);
        } error:^(NSError *error) {
            NSLog(@"err: %@", error);
        }];
    } else if (indexPath.row == 4) {
        [[[Query build:^(Query *q) {
            q.post(@"http://httpbin.org/post", @{@"7": @"bb", @"8": @"dd"});
        }] send] subscribeNext:^(id x) {
            NSLog(@"ok: %@", x);
        } error:^(NSError *error) {
            NSLog(@"err: %@", error);
        }];
    } else if (indexPath.row == 5) {
        [[[Query build:^(Query *q) {
            q.put(@"http://httpbin.org/put", @{@"9": @"bb", @"10": @"dd"});
        }] send] subscribeNext:^(id x) {
            NSLog(@"ok: %@", x);
        } error:^(NSError *error) {
            NSLog(@"err: %@", error);
        }];
    } else if (indexPath.row == 6) {
        [[[Query build:^(Query *q) {
            q.delete(@"http://httpbin.org/delete", @{@"11": @"bb", @"12": @"dd"});
        }] send] subscribeNext:^(id x) {
            NSLog(@"ok: %@", x);
        } error:^(NSError *error) {
            NSLog(@"err: %@", error);
        }];
    } else if (indexPath.row == 7) {
        [[[Country getAllContries] send] subscribeNext:^(id x) {
            NSLog(@"ok: %@", x);
        } error:^(NSError *error) {
            NSLog(@"err: %@", error);
        }];
    }
}

@end
