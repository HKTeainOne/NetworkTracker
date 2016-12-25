//
//  NTHTTPViewController.m
//  NetworkTracker
//
//  Created by LiQiu Yu on 16/2/17.
//  Copyright © 2016年 LiQiu Yu. All rights reserved.
//

#import "NTHTTPViewController.h"
#import "NTTrackerManager.h"
#import "NTHTTPModel.h"
#import "NTHTTPDetailViewController.h"

static NSString *const kNTHTTPCellIdentifier = @"kNTHTTPCellIdentifier";
static CGFloat const kNTHTTPCellHeight = 60.0;

@interface NTHTTPViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *dataSource;

@end

@implementation NTHTTPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor grayColor];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"NetworkTracker";
    UIBarButtonItem *hidenButton = [[UIBarButtonItem alloc] initWithTitle:@"hide" style:UIBarButtonItemStylePlain target:self action:@selector(hideAction)];
    self.navigationItem.leftBarButtonItem = hidenButton;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    _tableView = tableView;
    [self.view addSubview:_tableView];
    
    self.dataSource = [[NTTrackerManager manager] getHTTPModels];
}

- (void)hideAction {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [[NTTrackerManager manager] presentHTTPFloatingButtonViewController];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNTHTTPCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kNTHTTPCellIdentifier];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NTHTTPModel *model = _dataSource[indexPath.row];
    cell.textLabel.text = model.requestURLString;
    
    UIColor *titleColor=[UIColor colorWithRed:0.96 green:0.15 blue:0.11 alpha:1];
    if ([model.responseStatusCode isEqualToString:@"200"]) {
        titleColor=[UIColor colorWithRed:0.11 green:0.76 blue:0.13 alpha:1];
    }
    NSAttributedString *statusCode = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@   ",model.responseStatusCode]
                                                                            attributes:@{
                                                                             NSForegroundColorAttributeName: titleColor
                                                                                        }];
    
    NSAttributedString *methodAndTime = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@   %@   %@",model.requestHTTPMethod, model.startDateString, model.responseContentLengthString]
                                                                               attributes:@{
                                                                                            NSForegroundColorAttributeName: [UIColor grayColor]
                                                                                            }];
    
    NSMutableAttributedString *detail = [[NSMutableAttributedString alloc] init];
    [detail appendAttributedString:statusCode];
    [detail appendAttributedString:methodAndTime];
    
    cell.detailTextLabel.attributedText = detail;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kNTHTTPCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NTHTTPDetailViewController *detailVC = [[NTHTTPDetailViewController alloc] init];
    detailVC.model = _dataSource[indexPath.row];
    [self.navigationController pushViewController:detailVC animated:YES];
}
@end
