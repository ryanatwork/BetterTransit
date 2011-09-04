//
//  Constants.h
//  BetterTransit
//
//  Created by Yaogang Lian on 8/15/10.
//  Copyright 2010 Happen Next. All rights reserved.
//

#define AppDelegate (BTTransitDelegate *)[[UIApplication sharedApplication] delegate]

// ASIHTTPRequest types
#define REQUEST_TYPE_GET_XML 601
#define REQUEST_TYPE_GET_JSON 602
#define REQUEST_TYPE_GET_ICON 603
#define REQUEST_TYPE_GET_FEED 604

// Alert View Tags
#define TAG_BUY_ADS_FREE_VERSION 1

// Cell states
#define CELL_STATE_INITIALIZED 0
#define CELL_STATE_UPDATING 1
#define CELL_STATE_UPDATED 2

// Notification names
#define kStartUpdatingLocationNotification @"kStartUpdatingLocationNotification"
#define kDidUpdateToLocationNotification @"kDidUpdateToLocationNotification"
#define kDidFailToUpdateLocationNotification @"kDidFailToUpdateLocationNotification"
#define kLocationDidNotChangeNotification @"kLocationDidNotChangeNotification"
#define kRemoveAdsNotification @"kRemoveAdsNotification"

// Table view cell content offsets
#define kCellLeftOffset			12.0
#define kCellTopOffset			8.0
#define kCellHeight				22.0
#define kLabelFontSize			17

// List names
#define LIST_STARTUP_SCREEN @"LIST_STARTUP_SCREEN"
#define LIST_NEARBY_RADIUS @"LIST_NEARBY_RADIUS"
#define LIST_MAX_NUM_NEARBY_STOPS @"LIST_MAX_NUM_NEARBY_STOPS"

// Colors
#define COLOR_AD_REMOVAL [UIColor colorWithRed:0.639 green:0.851 blue:1.0 alpha:1.0]
//#define COLOR_AD_REMOVAL [UIColor colorWithRed:0.729 green:0.876 blue:1.0 alpha:1.0]
#define COLOR_DARK_RED [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1.0]

// NSUserDefault keys
#define KEY_STARTUP_SCREEN @"firstPage"
#define KEY_NEARBY_RADIUS @"nearbyRadius"
#define KEY_MAX_NUM_NEARBY_STOPS @"nearbyNumber"
#define KEY_LIFETIME_ADS_FREE @"KEY_LIFETIME_ADS_FREE"

// Misc.
#define kStringDelimitingCharacter		@"|||"
#define KEY_HAVE_SHOWN_TOOLTIP @"KEY_HAVE_SHOWN_TOOLTIP"

// Modes of view controllers
#define MODE_MODAL 0
#define MODE_PUSHED 1

// Download status
#define DOWNLOAD_STATUS_INIT 0
#define DOWNLOAD_STATUS_SUCCEEDED 1
#define DOWNLOAD_STATUS_FAILED 2
