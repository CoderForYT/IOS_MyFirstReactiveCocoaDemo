//
//  BookTableViewCellViewModel.m
//  MyFirstReactiveCocoaDemo
//
//  Created by zkhk on 16/4/28.
//  Copyright © 2016年 zkhk. All rights reserved.
//

#import "BookTableViewCellViewModel.h"

@implementation BookTableViewCellViewModel

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self initBind];
    return self;
}

- (void)initBind {
    
    @weakify(self);
    _buttonCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSubject createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            [subscriber sendNext:@(self.indexPath)];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    
    [[_buttonCommand.executionSignals flattenMap:^RACStream *(id value) {
        return value;
    }]
     subscribeNext:^(id x) {
         NSLog(@"%@",x);
     }];
    
}

@end
