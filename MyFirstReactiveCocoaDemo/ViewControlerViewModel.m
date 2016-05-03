//
//  ViewControlerViewModel.m
//  MyFirstReactiveCocoaDemo
//
//  Created by zkhk on 16/4/28.
//  Copyright © 2016年 zkhk. All rights reserved.
//

#import "ViewControlerViewModel.h"
#import "ZKHKNetworking.h"

@implementation ViewControlerViewModel

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self initBind];
    
    return self;
}


- (void)initBind{
    
        _requestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        RACSignal *signal =  [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            params[@"q"] = @"基础";
            [ZKHKNetworking getWithUrl:@"https://api.douban.com/v2/book/search" params:params success:^(NSDictionary *response) {
                
                [subscriber sendNext:response];
                [subscriber sendCompleted];
                
            } fail:^(NSError *error) {
                [subscriber sendError:error];
                [subscriber sendCompleted];
            }];
            return nil;
        }];
//        如果需要处理在这里做一个map,把处理好的数据传出去.       
        return [signal map:^id(NSMutableDictionary *value) {
           
            NSMutableArray *dictArr = value[@"books"];
            return dictArr;
            
        }];

    }];
}

@end
