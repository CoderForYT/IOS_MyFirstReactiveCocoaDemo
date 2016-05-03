//
//  LoginViewController.m
//  MyFirstReactiveCocoaDemo
//
//  Created by zkhk on 16/4/27.
//  Copyright © 2016年 zkhk. All rights reserved.
//

#import "LoginViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "LoginViewModel.h"
#import "Masonry.h"

@interface LoginViewController()
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) LoginViewModel *viewModel;
@end

@implementation LoginViewController

#pragma mark - lift cricle
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) return nil;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancle" style:UIBarButtonItemStyleDone target:nil action:nil];
    
    // 设置左上角的功能
    self.navigationItem.leftBarButtonItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    // 注册信号
    RAC(self.viewModel.account, userName) = self.userNameTextField.rac_textSignal;
    RAC(self.viewModel.account, password) = self.passwordTextField.rac_textSignal;
    RAC(self.loginButton, enabled) = self.viewModel.isLoginEnable;
    RAC(self.loginButton, backgroundColor) = [self.viewModel.isLoginEnable map:^id(NSNumber *value) {
        if (value.boolValue == YES) {
            return [UIColor greenColor];
        }else {
            return [UIColor grayColor];
        }
    }];
    
    // 登录点击
    [[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.viewModel.loginCommand execute:nil];
    }];
    // 注册登录信号
    [[self.viewModel.loginCommand.executionSignals flattenMap:^RACStream *(id value) {
        return value;
    }] subscribeNext:^(NSNumber *x) {
        if (x.integerValue == LoginStateSuccess) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else {
            NSLog(@"登录失败");
        }
    }];
}

#pragma makr - event response

#pragma mark - public methonds

#pragma mark - private methonds

#pragma mark - Setters

#pragma mark - Getters

- (LoginViewModel *)viewModel {
    if(_viewModel)
        return _viewModel;
    _viewModel = [[LoginViewModel alloc] init];
    return _viewModel;
}

@end
