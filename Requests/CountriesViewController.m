//
//  CountriesViewController.m
//  Requests
//
//  Created by shaohua on 2018/5/18.
//  Copyright © 2018 syang. All rights reserved.
//

#import "CountriesViewController.h"
#import "Country.h"
#import "UIScrollView+Refresh.h"
#import "Query.h"

@interface CountriesViewController ()

@property (nonatomic) NSArray *items;

@end

@implementation CountriesViewController

- (void)dealloc {
    NSLog(@"dealloc %@", self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 一次性的 UI 设置
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] init];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];

    // 一次性的数据设置：包括第一次加载
    @weakify(self);
    [self.tableView showHeaderAndFooter:[Country getAllContries] output:^(RACSignal *values, RACSignal *errors) {
        [values subscribeNext:^(Query *x) {
            @strongify(self)
            // 根据数据调整UI
            self.items = x.responseObject[1];
            NSLog(@"%@", x.responseObject[0]);
            [self.tableView reloadData];
        }];
        [errors subscribeNext:^(id x) {
            NSLog(@"pull header err %@", x);
        }];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    Country *c = _items[indexPath.row];
    cell.textLabel.text = c.name;
    cell.detailTextLabel.text = c.iso2Code;
    return cell;
}

@end
