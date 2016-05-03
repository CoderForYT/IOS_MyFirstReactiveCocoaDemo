//
//  BigImageViewModel.m
//  MyFirstReactiveCocoaDemo
//
//  Created by zkhk on 16/4/29.
//  Copyright © 2016年 zkhk. All rights reserved.
//

#import "BigImageViewModel.h"

@implementation BigImageViewModel

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    [self initBind];
    return self;
}

- (void)initBind {
    
    // 点击逻辑
    _tapCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@1];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    
    // 保存逻辑
    _saveCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(NSString *newTitle) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSMutableDictionary *newBook = [[NSMutableDictionary alloc] initWithDictionary:self.book];
            newBook[@"title"] = newTitle;
            self.book = newBook;
            [subscriber sendNext:newBook];
            [subscriber sendCompleted];
            return nil;
        }];
        
        
    }];
     
    
}



@end
