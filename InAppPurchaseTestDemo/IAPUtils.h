//
//  IAPUtils.h
//  InAppPurchaseTestDemo
//
//  Created by jj L on 2017/5/22.
//  Copyright © 2017年 jj L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAPUtils : NSObject

+ (instancetype)sharedInstance;

- (void)requestProductData:(NSString *)productId;

- (void)refreshReceipt;

@end
