//
//  ViewController.m
//  InAppPurchaseTestDemo
//
//  Created by jj L on 2017/5/18.
//  Copyright © 2017年 jj L. All rights reserved.
//

#import "ViewController.h"
#import "IAPUtils.h"
#import "RMStoreUtils.h"
#import <StoreKit/StoreKit.h>

static NSString *const ProductId0 = @"1234";
static NSString *const ProductId1 = @"123456";

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *productId;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"IAP Demo";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新账号" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonPressed)];
    
//    UIButton *buyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
//    buyButton.center = self.view.center;
//    [buyButton setTitle:@"立即购买" forState:UIControlStateNormal];
//    [buyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [buyButton addTarget:self action:@selector(buyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:buyButton];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

- (void)rightBarButtonPressed {
    [[IAPUtils sharedInstance] refreshReceipt];
}

- (void)buyButtonPressed:(UIButton *)button {
    NSLog(@"buy");
    [[IAPUtils sharedInstance] requestProductData:ProductId1];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"Product %@", @(indexPath.row)];
    if (indexPath.section == 1) {
        NSArray<NSString *> *productIds = @[ProductId0, ProductId1];
        [[RMStoreUtils sharedInstance] requestProductsWithProductIds:productIds success:^(NSArray<SKProduct *> *product) {
            SKProduct *p = product[indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@（￥%.2f）", p.localizedTitle, p.price.floatValue];
        } fail:^(NSError *error) {
            
        }];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [[IAPUtils sharedInstance] requestProductData:ProductId0];
        } else {
            [[IAPUtils sharedInstance] requestProductData:ProductId1];
        }
    } else {
        NSArray<NSString *> *productIds = @[ProductId0, ProductId1];
        [[RMStoreUtils sharedInstance] paymentWithProductId:productIds[indexPath.row] success:^(SKPaymentTransaction *transaction) {
            
        } fail:^(SKPaymentTransaction *transaction, NSError *error) {
            
        }];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"IAP";
    }
    return @"RMStore";
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return FLT_MIN;
}

@end
