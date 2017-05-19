//
//  ViewController.m
//  InAppPurchaseTestDemo
//
//  Created by jj L on 2017/5/18.
//  Copyright © 2017年 jj L. All rights reserved.
//

#import "ViewController.h"
#import <StoreKit/StoreKit.h>

#define SANDBOX @"https://sandbox.itunes.apple.com/verifyReceipt"

static NSString *const ProductId = @"1234";

@interface ViewController ()<SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (nonatomic, strong) NSString *productId;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    UIButton *buyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    buyButton.center = self.view.center;
    [buyButton setTitle:@"立即购买" forState:UIControlStateNormal];
    [buyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [buyButton addTarget:self action:@selector(buyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buyButton];
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)buyButtonPressed:(UIButton *)button {
    NSLog(@"buy");
    if ([SKPaymentQueue canMakePayments]) {
        [self requestProductData:ProductId];
    } else {
        NSLog(@"不允许App内购");
    }
}

// 去苹果服务器请求商品
- (void)requestProductData:(NSString *)type {
    NSArray *products = [NSArray arrayWithObjects:type, nil];
    NSSet *productSet = [NSSet setWithArray:products];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productSet];
    request.delegate = self;
    [request start];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"-------------------收到商品反馈信息--------------------");
    NSArray *products = response.products;
    if (products.count == 0) {
        NSLog(@"------------没有商品---------");
        return;
    }
    
    NSLog(@"productID: %@", response.invalidProductIdentifiers);
    NSLog(@"商品数量: %@", @(products.count));
    
    SKProduct *product = nil;
    for (SKProduct *p in products) {
        NSLog(@"description: %@", p.description);
        NSLog(@"localizedTitle: %@", p.localizedTitle);
        NSLog(@"localizedDescription: %@", p.localizedDescription);
        NSLog(@"price: %@", p.price);
        NSLog(@"productIdentifier: %@", p.productIdentifier);
        if ([p.productIdentifier isEqualToString:ProductId]) {
            product = p;
        }
    }
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    NSLog(@"发送购买请求");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKRequestDelegate

- (void)requestDidFinish:(SKRequest *)request {
    NSLog(@"请求成功");
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"请求失败----%@", error);
}

// 验证购买，避免越狱软件请求非法购买
- (void)verifyPurchaseWithPaymentTransaction {
    // 从沙盒中获取交易凭证并拼接成请求体数据
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    NSString *receiptString = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\": \"%@\"}", receiptString];
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    // 创建请求到苹果官方进行购买验证
    NSURL *url = [NSURL URLWithString:SANDBOX];
    NSMutableURLRequest *requests = [NSMutableURLRequest requestWithURL:url];
    requests.HTTPBody = bodyData;
    requests.HTTPMethod = @"POST";
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:requests returningResponse:nil error:&error];
    if (error) {
        NSLog(@"验证购买过程中发生错误，错误信息：%@", error.localizedDescription);
        return;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"%@", dict);
    if ([dict[@"status"] integerValue] == 0) {
        NSLog(@"购买成功！");
        NSDictionary *dictReceipt = dict[@"receipt"];
        NSDictionary *dictInApp = [dictReceipt[@"in_app"] firstObject];
        NSString *productIdentifier = dictInApp[@"product_id"];
        // 如果是消耗品则记录购买数量，非消耗品则记录是否购买过
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([productIdentifier isEqualToString:ProductId]) {
            NSInteger purchasedCount = [defaults integerForKey:productIdentifier];
            [[NSUserDefaults standardUserDefaults] setInteger:purchasedCount + 1 forKey:productIdentifier];
        } else {
            [defaults setBool:YES forKey:productIdentifier];
        }
    } else {
        NSLog(@"购买失败，未通过验证！");
    }
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:{
                NSLog(@"交易完成！");
                // 发送到苹果服务器验证凭证
                [self verifyPurchaseWithPaymentTransaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
                break;
                
            case SKPaymentTransactionStatePurchasing:{
                NSLog(@"商品添加进列表！");
            }
                break;
                
            case SKPaymentTransactionStateRestored:{
                NSLog(@"已经购买过该商品");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
                break;
                
            case SKPaymentTransactionStateDeferred:{
                NSLog(@"最终状态未确定");
            }
                break;
                
            case SKPaymentTransactionStateFailed:{
                NSLog(@"交易失败！");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"交易结束");
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

@end
