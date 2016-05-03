//
// Created by zkhk on 16/4/27.
// Copyright (c) 2016 zkhk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

typedef NS_ENUM(NSUInteger, LoginState) {
    LoginStateFail,
    LoginStateSuccess,
};

@class Account;

@interface LoginViewModel : NSObject

@property (strong, nonatomic) Account *account;
@property (strong, nonatomic) RACCommand *loginCommand;
@property (strong, nonatomic) RACSignal *isLoginEnable;

@end


@interface Account : NSObject

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *password;

@end