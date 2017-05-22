//
//  RMStoreUtils.h
//  InAppPurchaseTestDemo
//
//  Created by jj L on 2017/5/22.
//  Copyright © 2017年 jj L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMStore.h"

@interface RMStoreUtils : NSObject

+ (instancetype)sharedInstance;

- (void)requestProductsWithProductIds:(NSArray<NSString *> *)productIds
                              success:(void (^)(NSArray<SKProduct *> *product))success
                                 fail:(void (^)(NSError *error))fail;

- (void)paymentWithProductId:(NSString *)productId
                     success:(void (^)(SKPaymentTransaction *transaction))success
                        fail:(void (^)(SKPaymentTransaction *transaction, NSError *error))fail;

@end
