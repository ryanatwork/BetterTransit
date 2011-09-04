//
//  InAppPurchaseManager.m
//  BetterTransit
//
//  Created by Yaogang Lian on 2/12/11.
//  Copyright 2011 Happen Next. All rights reserved.
//

#import "InAppPurchaseManager.h"
#import "BTTransitDelegate.h"
#import "LoadingView.h"
#import "Utility.h"

@implementation InAppPurchaseManager


#pragma mark -
#pragma mark Singleton

static InAppPurchaseManager *sharedInstance = nil;
+ (InAppPurchaseManager *)sharedInstance
{
	if (sharedInstance == nil) {
		sharedInstance = [[InAppPurchaseManager alloc] init];
	}
	return sharedInstance;
}


#pragma mark -
#pragma mark Initialization

- (id)init
{
	if (self = [super init])
	{
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	}
	return self;
}

- (void)dealloc
{
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
	[super dealloc];
}


#pragma mark -
#pragma mark Make requests

- (void)purchaseAdsFreeVersion
{
	if ([SKPaymentQueue canMakePayments])
	{
		[LoadingView showWithText:@"Processing..." inView:[AppDelegate tabBarController].view];
		
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:PRODUCT_ID_REMOVE_ADS];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
		
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"pending_transaction"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void)restorePendingTransactions
{
	[LoadingView showWithText:@"Processing..." inView:[AppDelegate tabBarController].view];
	
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}
	
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
	if ([transaction.payment.productIdentifier isEqualToString:PRODUCT_ID_REMOVE_ADS])
	{
		// save the transaction receipt to disk
		[[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"removeAdsTransactionReceipt"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

// Remove the transaction from the queue and posts a notification with the transaction result
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)successful
{
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
	if (successful)
	{
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_LIFETIME_ADS_FREE];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[[NSNotificationCenter defaultCenter] postNotificationName:kRemoveAdsNotification object:nil];
	}
	else
	{
		[Utility showErrorDialog:@"Failed to process the payment. You were not charged."];
	}
	[LoadingView dismiss];
}


#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	for (SKPaymentTransaction *transaction in transactions)
	{
		switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchased:
			{
				[self recordTransaction:transaction];
				[self finishTransaction:transaction wasSuccessful:YES];
			}
				break;
			case SKPaymentTransactionStateRestored:
			{
				[self recordTransaction:transaction];
				[self finishTransaction:transaction wasSuccessful:YES];
			}
				break;
			case SKPaymentTransactionStateFailed:
			{
				if (transaction.error.code != SKErrorPaymentCancelled)
				{
					[self finishTransaction:transaction wasSuccessful:NO];
					//[Utility showErrorDialog:[NSString stringWithFormat:@"%@", transaction.error]];
				}
				else
				{
					// this is fine, the user just cancelled, so don't notify
					[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
					[LoadingView dismiss];
				}
			}
				break;
			default:
				break;
		}
	}
	
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"pending_transaction"];
}


/*
#pragma mark -
#pragma mark Make request

- (void)requestRemoveAdsProductData
{
	NSSet *productIdentifiers = [NSSet setWithObject:PRODUCT_ID_REMOVE_ADS];
	productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
	productsRequest.delegate = self;
	
	[LoadingView showWithText:@"Processing..."];
	[productsRequest start];
	
	// we will release the request object in the delegate callback
}

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
 
#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	NSArray *products = response.products;
	removeAdsProduct = ([products count] == 1) ? [[products objectAtIndex:0] retain] : nil;
	if (removeAdsProduct) {
		NSLog(@"Product title: %@", removeAdsProduct.localizedTitle);
		NSLog(@"Product description: %@", removeAdsProduct.localizedDescription);
		NSLog(@"Product price: %@", removeAdsProduct.price);
		NSLog(@"Product id: %@", removeAdsProduct.productIdentifier);
	}
	
	for (NSString *invalidProductId in response.invalidProductIdentifiers) {
		NSLog(@"Invalid product id: %@", invalidProductId);
	}
	
	// finally release the request we alloc'ed earlier
	[productsRequest release];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
	
	[LoadingView dismiss];
}
 */

@end
