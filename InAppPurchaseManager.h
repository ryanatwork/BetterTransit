//
//  InAppPurchaseManager.h
//  BetterTransit
//
//  Created by Yaogang Lian on 2/12/11.
//  Copyright 2011 Happen Next. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>


@interface InAppPurchaseManager : NSObject
<SKPaymentTransactionObserver>
{
	SKProduct *removeAdsProduct;
	SKProductsRequest *productsRequest;
}

+ (InAppPurchaseManager *)sharedInstance;

- (void)purchaseAdsFreeVersion;
- (void)restorePendingTransactions;

@end
