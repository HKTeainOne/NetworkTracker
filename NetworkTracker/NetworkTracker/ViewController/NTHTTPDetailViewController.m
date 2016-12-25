//
//  NTHTTPDetailViewController.m
//  NetworkTracker
//
//  Created by LiQiu Yu on 16/2/17.
//  Copyright © 2016年 LiQiu Yu. All rights reserved.
//

#import "NTHTTPDetailViewController.h"
#import "NTHTTPContentViewController.h"
#import "NTHTTPModel.h"

static NSString *const kNTHTTPDetailCellIdentifier = @"kNTHTTPDetailCellIdentifier";

@interface NTHTTPDetailViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *detailTitles;
@property (nonatomic, assign) CGFloat cellHeight;

@end

@implementation NTHTTPDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _model.requestURL.host;
    self.detailTitles = @[@"Request Url",@"Status Code",@"Method",@"Mime Type",@"Start Time",@"Total Duration",@"Conetnt Length", @"Request Body",@"Response Body"];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    _tableView = tableView;
    [self.view addSubview:_tableView];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _detailTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNTHTTPDetailCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kNTHTTPDetailCellIdentifier];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = _detailTitles[indexPath.row];
    
    NSString *detail;
    switch (indexPath.row) {
        case 0:detail = _model.requestURLString;break;
        case 1: detail = _model.responseStatusCode; break;
        case 2: detail = _model.requestHTTPMethod; break;
        case 3: detail = _model.responseMIMEType; break;
        case 4: detail = _model.startDateString; break;
        case 5: detail = [NSString stringWithFormat:@"%ldms",(long)(_model.duration*1000)]; break;
        case 6: detail = _model.responseContentLengthString; break;
        case 7:
            detail = _model.requestHTTPBody;
            if (![detail isEqualToString:@""]) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
        case 8:
            detail = _model.responseHTTPBody;
            if (![detail isEqualToString:@""]) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
        default:
            break;
    }
    if (!detail || [detail isEqualToString:@""]) {
        detail = @"empty";
    }
    cell.detailTextLabel.text = detail;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 7 ) {
        if (![_model.requestHTTPBody isEqualToString:@""]) {
            NTHTTPContentViewController *contentVC = [[NTHTTPContentViewController alloc] init];
            contentVC.contentString = _model.requestHTTPBody;
            [self.navigationController pushViewController:contentVC animated:YES];
        }
    }
    if (indexPath.row == 8 ) {
        if (![_model.responseHTTPBody isEqualToString:@""]) {
            NTHTTPContentViewController *contentVC = [[NTHTTPContentViewController alloc] init];
            contentVC.contentString = _model.responseHTTPBody;
            [self.navigationController pushViewController:contentVC animated:YES];
        }
    }
}
@end
