//
//  RMStoreUtils.m
//  InAppPurchaseTestDemo
//
//  Created by jj L on 2017/5/22.
//  Copyright © 2017年 jj L. All rights reserved.
//

#import "RMStoreUtils.h"

@implementation RMStoreUtils

+ (instancetype)sharedInstance {
    static RMStoreUtils *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)requestProductsWithProductIds:(NSArray<NSString *> *)productIds
                              success:(void (^)(NSArray<SKProduct *> *product))success
                                 fail:(void (^)(NSError *error))fail {
    NSMutableArray<NSString *> *responseProducts = [NSMutableArray array];
    [[RMStore defaultStore] requestProducts:[NSSet setWithArray:productIds] success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        if (products.count == 0) {
            NSLog(@"---------------没有商品-----------------");
        } else {
            for (SKProduct *product in products) {
                NSString *info = [NSString stringWithFormat:@"%@（%@）", product.localizedTitle, product.price];
                [responseProducts addObject:info];
            }
            NSLog(@"---------------请求商品成功-----------------");
            NSLog(@"%@", products);
            NSLog(@"%@", invalidProductIdentifiers);
            success(products);
        }
    } failure:^(NSError *error) {
        NSLog(@"---------------请求商品失败-----------------");
        fail(error);
    }];
//    return [responseProducts copy];
}

- (void)paymentWithProductId:(NSString *)productId
                     success:(void (^)(SKPaymentTransaction *transaction))success
                        fail:(void (^)(SKPaymentTransaction *transaction, NSError *error))fail {
    if ([RMStore canMakePayments]) {
        [[RMStore defaultStore] addPayment:productId success:^(SKPaymentTransaction *transaction) {
            NSLog(@"---------------交易成功-----------------");
            NSLog(@"%@", transaction);
            success(transaction);
        } failure:^(SKPaymentTransaction *transaction, NSError *error) {
            NSLog(@"---------------交易失败-----------------");
            NSLog(@"%@", transaction);
            NSLog(@"%@", error);
            fail(transaction, error);
        }];
    } else {
        NSLog(@"不允许App内购！");
    }
}

@end
