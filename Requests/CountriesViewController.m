//
//  CountriesViewController.m
//  Requests
//
//  Created by shaohua on 2018/5/18.
//  Copyright © 2018 syang. All rights reserved.
//

#import "CountriesViewController.h"
#import "UIViewController+Query.h"
#import "UIScrollView+Refresh.h"
#import "Country.h"

@interface CountriesViewController ()

@property (nonatomic) NSArray *items;

@end

@implementation CountriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 一次性的 UI 设置
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] init];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];

    // 一次性的数据设置：包括第一次加载
    RACCommand *cmd = [self commandWithQuery:[Country getAllContries]];
    @weakify(self);
    [[self.tableView showHeaderAndFooterWithCommand:cmd] subscribeNext:^(id x) {
        @strongify(self)
        // 根据数据调整UI
        self.items = x;
        [self.tableView reloadData];
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
    Country *c = _items[indexPath.row];
    cell.textLabel.text = c.name;
    cell.detailTextLabel.text = c.iso2Code;
    return cell;
}

@end
