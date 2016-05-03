//
//  ViewController.m
//  MyFirstReactiveCocoaDemo
//
//  Created by zkhk on 16/4/27.
//  Copyright © 2016年 zkhk. All rights reserved.
//

/*
    需求:
    做一个登录界面
    一个tableView进行数据的展示
    点击cell里面的按钮, 进行处理
    点击cell ,调整到对应的展示页面, 并对数据进行修改
 */

#import "ViewController.h"
#import "LoginViewController.h"
#import "BigImageViewController.h"
#import "ViewControlerViewModel.h"
#import "BookTableViewCell.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "Masonry.h"
#import "UIImageView+WebCache.h"




@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) ViewControlerViewModel *viewModel;
@property (strong, nonatomic) NSMutableArray *books;

@end

@implementation ViewController


#pragma mark - lift cricle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupViewContrller];

    // tableView约束
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(@0);
    }];
    
    // 获取数据
    @weakify(self);
    RACSignal *requestSignal = [self.viewModel.requestCommand execute:nil];
    [requestSignal subscribeNext:^(NSMutableArray *boosArr) {
        @strongify(self);
        [self.books addObjectsFromArray:boosArr];
        [self.tableView reloadData];
    }];
}

- (void)setupViewContrller {
    self.title = @"主界面";
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleDone target:nil action:nil];
    // 右上角的事件
    @weakify(self);
    self.navigationItem.rightBarButtonItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            LoginViewController  *loginVC = [[LoginViewController alloc] init];
            loginVC.title = @"登录";
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.books.count * 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BookTableViewCell *cell = [BookTableViewCell bookTableViewCellWithTableView:tableView];
    NSInteger path = indexPath.row % 10;
    NSDictionary *book = [self.books objectAtIndex: path];
    cell.viewModel.book = book;
    cell.viewModel.indexPath = indexPath.row;
    // 不能在这里处理时间, 这里会有问题, 要放到viewmodel里面处理
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BigImageViewController *vc = [[BigImageViewController alloc] init];
    vc.title = @"详情";
    NSInteger path = indexPath.row % 10;
    NSDictionary *book = [self.books objectAtIndex: path];
    vc.book = book;
    
    // 监听vc的book属性
    [RACObserve(vc, book) subscribeNext:^(NSDictionary *newBook) {
        NSLog(@"View_book_%@", newBook[@"title"]);
        [self.books setObject:newBook atIndexedSubscript:path];
        [self.tableView reloadData];
    }];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma makr - event response

#pragma mark - public methonds

#pragma mark - private methonds

#pragma mark - Setters

#pragma mark - Getters

-(ViewControlerViewModel *)viewModel {
    
    if (_viewModel) {
        return _viewModel;
    }
    _viewModel = [[ViewControlerViewModel alloc] init];
    return _viewModel;
}

- (UITableView *)tableView {
    if (_tableView) {
        return _tableView;
    }
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
    return _tableView;
}

-(NSMutableArray *)books {
    if (_books) {
        return _books;
    }
    _books = [[NSMutableArray alloc] init];
    return _books;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
