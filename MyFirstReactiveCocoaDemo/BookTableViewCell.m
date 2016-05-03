//
//  BookTableViewCell.m
//  MyFirstReactiveCocoaDemo
//
//  Created by zkhk on 16/4/28.
//  Copyright © 2016年 zkhk. All rights reserved.
//

#import "BookTableViewCell.h"
#import "UIImageView+WebCache.h"


@interface BookTableViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation BookTableViewCell


+ (instancetype)bookTableViewCellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"Cell";
    BookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:ID];
        cell = [tableView dequeueReusableCellWithIdentifier:ID];
    }
    return cell;
}

#pragma mark - setter
- (BookTableViewCellViewModel *)viewModel {
    if (_viewModel) {
        return _viewModel;
    }
    _viewModel = [[BookTableViewCellViewModel alloc] init];
    return _viewModel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
//     Initialization code
    
    [[self.button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.viewModel.buttonCommand execute:nil];
    }];
    
    @weakify(self);
    [RACObserve(self.viewModel, book) subscribeNext:^(NSDictionary *book) {
        @strongify(self);
        [self.bookImageView sd_setImageWithURL:book[kBookImage] placeholderImage:[UIImage imageNamed:@"15b0e51b906c9e8520633014beaac82d.jpg"]];
        self.bookTitleLabel.text = book[kBookTitle];
        self.bookPublisher.text = book[kBookPublisher];
        self.bookAuthorLabel.text = [book[kBookAuthor] lastObject];
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
