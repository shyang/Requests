//
//  ViewController.m
//  Requests
//
//  Created by shaohua on 2018/5/11.
//  Copyright © 2018 syang. All rights reserved.
//

#import "ViewController.h"
#import "Query.h"

@interface ViewController ()

@property (nonatomic) NSArray *items;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _items = @[@"Basic Auth", @"POST Multipart"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://httpbin.org"] sessionConfiguration:configuration];
        Query.manager = manager;

        RACSignal *retrySignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Auth" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {

            }];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                configuration.HTTPAdditionalHeaders = @{@"Authorization": @"Basic ZGVtbzpkZW1v"}; // demo:demo
                (void)[manager initWithBaseURL:manager.baseURL sessionConfiguration:configuration];

                [subscriber sendNext:@1];
                [subscriber sendCompleted];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }]];
            [self presentViewController:alert animated:YES completion:^{

            }];
            return nil;
        }];

        Query.adapter = ^RACSignal *(RACSignal *input) {
            return [[input materialize] flattenMap:^(RACEvent *event) {
                // [event.error.userInfo[@"result"] isEqualToString:@"login"]
                NSHTTPURLResponse *response = event.error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                if (event.eventType == RACEventTypeError && response.statusCode == 401) {
                    return [retrySignal flattenMap:^RACSignal *(id value) {
                        // 成功登录后，再试一次刚才的请求。
                        return value ? input : [RACSignal error:event.error];
                    }];
                }
                return [[RACSignal return:event] dematerialize];
            }];
        };

        /*
         basic auth 会触发 URLSession:task:didReceiveChallenge:completionHandler:
         AFN 会再发起一次重复网络请求
         https://forums.developer.apple.com/thread/39293
         */
        [[[Query build:^(Query *q) {
            q.get(@"/basic-auth/demo/demo");
        }] send] subscribeNext:^(id x) {
            NSLog(@"ok: %@", x);
        } error:^(NSError * _Nullable error) {
            NSLog(@"err: %@", error);
        }];

    } else if (indexPath.row == 1) {
        [[[Query build:^(Query *q) {
            q.post(@"http://localhost:4000/1etxc0v1");
        }] send] subscribeNext:^(id x) {
            NSLog(@"ok: %@", x);
        } error:^(NSError *error) {
            NSLog(@"err: %@", error);
        }];
    }
}
@end
