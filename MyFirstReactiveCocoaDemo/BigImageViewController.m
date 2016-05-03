//
//  BitImageViewController.m
//  MyFirstReactiveCocoaDemo
//
//  Created by zkhk on 16/4/29.
//  Copyright © 2016年 zkhk. All rights reserved.
//

#import "BigImageViewController.h"
#import "BigImageViewModel.h"
#import "UIImageView+WebCache.h"


@interface BigImageViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *bigImageView;
@property (weak, nonatomic) IBOutlet UILabel *bigTitleLabel;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *bigImageTap;
@property (strong, nonatomic) BigImageViewModel *viewModel;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) NSString *titleString;

@end

@implementation BigImageViewController

#pragma mark - lift cricle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 监听设值
    [RACObserve(self.viewModel, book) subscribeNext:^(NSDictionary *book) {
        [self.bigImageView sd_setImageWithURL:book[@"image"] placeholderImage:[UIImage imageNamed:@"15b0e51b906c9e8520633014beaac82d.jpg"]];
        self.titleTextField.text = book[@"title"];
    }];
    
    [self.bigImageTap.rac_gestureSignal subscribeNext:^(id x) {
        [self.viewModel.tapCommand execute:nil];
    }];

    // 点击图片
    @weakify(self);
    [[self.viewModel.tapCommand.executionSignals flattenMap:^RACStream *(id value) {
        return value;
    }]
     subscribeNext:^(id x) {
         @strongify(self);
         [self.navigationController popViewControllerAnimated:YES];
    }];
    self.viewModel.book = self.book;
    
    // 右上角薄村
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:nil action:nil];
    
    self.navigationItem.rightBarButtonItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [self.viewModel.saveCommand execute:self.titleString];
        return [RACSignal empty];
    }];
    
    RAC(self,titleString) = self.titleTextField.rac_textSignal;
    
    // 保存 
    [[self.viewModel.saveCommand.executionSignals flattenMap:^RACStream *(id value) {
        return value;
    }]
     subscribeNext:^(NSDictionary *newBook) {
         
         @strongify(self);
         self.book = newBook;
         [self.navigationController popViewControllerAnimated:YES];
     }];

}


#pragma mark - Getters
-(BigImageViewModel *)viewModel {
    if (_viewModel) {
        return _viewModel;
    }
    _viewModel = [[BigImageViewModel alloc] init];
    return _viewModel;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
