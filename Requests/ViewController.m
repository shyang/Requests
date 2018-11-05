//
//  ViewController.m
//  Requests
//
//  Created by shaohua on 2018/5/11.
//  Copyright © 2018 syang. All rights reserved.
//

#import "AFHTTPSessionManager+RACSignal.h"
#import "AppConfig.h"
#import "CountriesViewController.h"
#import "Country.h"
#import "ViewController.h"
#import "FooApi.h"

@interface ViewController ()

@property (nonatomic) NSArray *items;

@end

@implementation ViewController

- (void)dealloc {
    NSLog(@"dealloc %@", self);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    AFHTTPSessionManager *manager = [AppConfig manager];
    AFHTTPSessionManager *imageMgr = [manager copy];
    imageMgr.responseSerializer = [AFImageResponseSerializer serializer];

    AFHTTPSessionManager *rawMgr = [manager copy];
    rawMgr.responseSerializer = [AFHTTPResponseSerializer serializer];

    AFHTTPSessionManager *jsonMgr = [manager copy];
    jsonMgr.requestSerializer = [AFJSONRequestSerializer serializer];

    @weakify(self);
    _items = @[
        @[@"401 Basic Auth", ^{
            /*
             basic auth 会触发 URLSession:task:didReceiveChallenge:completionHandler:
             AFN 会再发起一次重复网络请求
             https://forums.developer.apple.com/thread/39293
             */
            [[manager GET:@"http://httpbin.org/basic-auth/demo/demo" config:nil] subscribeNext:^(id x) {
                NSLog(@"ok: %@", x);
            } error:^(NSError *error) {
                NSLog(@"err: %@", error);
            }];
        }],
        @[@"GET ?query-string", ^{
            [[manager GET:@"http://httpbin.org/get" config:^(Query *q) {
                [q.parameters addEntriesFromDictionary:@{@"1": @"bb", @"2": @"dd"}];
            }] subscribeNext:^(id x) {
                NSLog(@"ok: %@", x);
            } error:^(NSError *error) {
                NSLog(@"err: %@", error);
            }];

        }],
        @[@"POST multipart/form-data", ^{
            [[manager POST:@"http://httpbin.org/post" config:^(Query *q) {
                [q.parameters addEntriesFromDictionary:@{@"3": @"bb", @"4": @"dd"}];
                q.multipartBody = ^(id<AFMultipartFormData> formData) {
                    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Info" withExtension:@"plist"];
                    NSData *d = [NSData dataWithContentsOfURL:url];
                    [formData appendPartWithFormData:d name:@"m3"];
                };
            }] subscribeNext:^(id x) {
                NSLog(@"ok: %@", x);
            } error:^(NSError *error) {
                NSLog(@"err: %@", error);
            }];
        }],
        @[@"POST application/json", ^{
            [[jsonMgr POST:@"http://httpbin.org/post" config:^(Query *q) {
                q.jsonBody = @{@"5": @"bb", @"6": @"dd"};
            }] subscribeNext:^(id x) {
                NSLog(@"ok: %@", x);
            } error:^(NSError *error) {
                NSLog(@"err: %@", error);
            }];
        }],
        @[@"POST application/x-www-form-urlencoded", ^{
            [[manager POST:@"http://httpbin.org/post" config:^(Query *q) {
                [q.parameters addEntriesFromDictionary:@{@"7": @"bb", @"8": @"dd"}];
            }] subscribeNext:^(id x) {
                NSLog(@"ok: %@", x);
            } error:^(NSError *error) {
                NSLog(@"err: %@", error);
            }];
        }],
        @[@"PUT application/json", ^{
            [[jsonMgr PUT:@"http://httpbin.org/put" config:^(Query *q) {
                q.jsonBody = @{@"9": @"bb", @"10": @"dd"};
            }] subscribeNext:^(id x) {
                NSLog(@"ok: %@", x);
            } error:^(NSError *error) {
                NSLog(@"err: %@", error);
            }];
        }],
        @[@"DELETE ?query-string", ^{
            [[manager DELETE:@"http://httpbin.org/delete" config:^(Query *q) {
                [q.parameters addEntriesFromDictionary:@{@"11": @"bb", @"12": @"dd"}];
            }] subscribeNext:^(id x) {
                NSLog(@"ok: %@", x);
            } error:^(NSError *error) {
                NSLog(@"err: %@", error);
            }];
        }],
        @[@"Parse by Mantle", ^{
            [[Country getAllContries] subscribeNext:^(id x) {
                NSLog(@"ok: %@", x);
            } error:^(NSError *error) {
                NSLog(@"err: %@", error);
            }];
        }],
        @[@"Pull to refresh", ^{
            @strongify(self);
            [self.navigationController pushViewController:[CountriesViewController new] animated:YES];
        }],
        @[@"GET 500", ^{
            [[manager GET:@"http://httpbin.org/status/500" config:nil] subscribeNext:^(id x) {
                NSLog(@"ok: %@", x);
            } error:^(NSError *error) {
                NSLog(@"err: %@", error);
            }];
        }],
        @[@"GET 499", ^{
            [[manager GET:@"http://httpbin.org/status/{code}" config:^(Query *q) {
                q.parameters[@"code"] = @499;
            }] subscribeNext:^(id x) {
                NSLog(@"ok: %@", x);
            } error:^(NSError *error) {
                NSLog(@"err: %@", error);
            }];
        }],
        @[@"GET 599", ^{
            FooApi *foo = [FooApi new];
            foo.userId = @599;
            [[foo send] subscribeNext:^(id x) {
                NSLog(@"ok: %@", x);
            } error:^(NSError *error) {
                NSLog(@"err: %@", error);
            }];
        }],
        @[@"GET Image body", ^{
            [[imageMgr GET:@"http://httpbin.org/image/jpeg" config:nil] subscribeNext:^(id x) {
                NSLog(@"ok: %@", x);
            } error:^(NSError *error) {
                NSLog(@"err: %@", error);
            }];
        }],
        @[@"GET Blob body", ^{
            [[rawMgr GET:@"http://httpbin.org/image/png" config:nil] subscribeNext:^(id x) {
                NSLog(@"ok: %@", x);
            } error:^(NSError *error) {
                NSLog(@"err: %@", error);
            }];
        }],
        @[@"Etag & Last-Modified", ^{
            [[manager GET:@"http://httpbin.org/cache" parameters:nil] subscribeNext:^(id x) {
                NSLog(@"%@", x);
            } error:^(NSError *error) {
                NSLog(@"%@", error);
            }];
        }]
    ];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.text = _items[indexPath.row][0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    void (^block)(void) = _items[indexPath.row][1];
    block();
}

@end
