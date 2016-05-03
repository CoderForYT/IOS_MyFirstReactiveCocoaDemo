//
// Created by zkhk on 16/4/27.
// Copyright (c) 2016 zkhk. All rights reserved.
//

#import "LoginViewModel.h"


@implementation LoginViewModel

- (instancetype)init {
    self = [super init];
    if (!self) return nil;

    [self initBind];
    return self;
}

- (void)initBind {
    
    _isLoginEnable = [RACSignal combineLatest:@[RACObserve(self.account, userName), RACObserve(self.account, password)] reduce:^id(NSString *userName, NSString *password){
       
        return @(userName.length > 3 && password.length > 6);
    }];
    
    
    
    _loginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
       
       
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            if ([self.account.userName isEqualToString:@"user"] && [self.account.password isEqualToString:@"password"]) {
                [subscriber sendNext:@(LoginStateSuccess)];
            }else {
                [subscriber sendNext:@(LoginStateFail)];
            }
            [subscriber sendCompleted];
            
            return nil;
        }];
        return signal;
    }];
}


- (Account *)account {
    if (_account) {
        return _account;
    }
    _account = [[Account alloc] init];
    return _account;
}


@end

@implementation Account

@end