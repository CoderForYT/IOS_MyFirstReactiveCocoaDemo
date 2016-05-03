//
//  BookTableViewCell.h
//  MyFirstReactiveCocoaDemo
//
//  Created by zkhk on 16/4/28.
//  Copyright © 2016年 zkhk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookTableViewCellViewModel.h"

@interface BookTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *bookImageView;
@property (weak, nonatomic) IBOutlet UILabel *bookTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bookAuthorLabel;
@property (weak, nonatomic) IBOutlet UILabel *bookPublisher;

@property (strong, nonatomic) BookTableViewCellViewModel *viewModel;
+ (instancetype)bookTableViewCellWithTableView:(UITableView *)tableView;

@end
