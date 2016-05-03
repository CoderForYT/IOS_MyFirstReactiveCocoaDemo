//
//  BigImageViewModel.h
//  MyFirstReactiveCocoaDemo
//
//  Created by zkhk on 16/4/29.
//  Copyright © 2016年 zkhk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface BigImageViewModel : NSObject

@property (strong, nonatomic) NSDictionary *book;
@property (strong, nonatomic) RACCommand *tapCommand;
@property (strong, nonatomic) RACCommand *saveCommand;
@end
