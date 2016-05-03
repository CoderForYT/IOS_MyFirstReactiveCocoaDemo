//
//  BookTableViewCellViewModel.h
//  MyFirstReactiveCocoaDemo
//
//  Created by zkhk on 16/4/28.
//  Copyright © 2016年 zkhk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

static NSString const *kBookImage = @"image";
static NSString const *kBookTitle = @"title";
static NSString const *kBookPublisher = @"publisher";
static NSString const *kBookAuthor = @"author";

@interface BookTableViewCellViewModel : NSObject

@property (strong, nonatomic) RACCommand *buttonCommand;
@property (assign, nonatomic) NSInteger indexPath;
@property (strong, nonatomic) NSDictionary *book;
@end
