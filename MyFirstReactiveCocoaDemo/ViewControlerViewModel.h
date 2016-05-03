//
//  ViewControlerViewModel.h
//  MyFirstReactiveCocoaDemo
//
//  Created by zkhk on 16/4/28.
//  Copyright © 2016年 zkhk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ViewControlerViewModel : NSObject

@property (strong, nonatomic) RACCommand *requestCommand;

@end
