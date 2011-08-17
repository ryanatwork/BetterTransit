/*
 *  Settings.h
 *  BetterTransit
 *
 *  Created by Yaogang Lian on 11/9/09.
 *  Copyright 2009 Happen Next. All rights reserved.
 *
 */

//#define PRODUCTION_READY

#define FAKE_LOCATION_LATITUDE 38.034039
#define FAKE_LOCATION_LONGITUDE -78.499479

#define UTS 1
#define CTS 2

// Custom settings
#define MAIN_DB @"HoosBus"
#define PRODUCT_ID_REMOVE_ADS @"com.yaoganglian.hoosbus.removeads"
#define ADD_TO_FAVS_PNG @"addToFavs.png"
#define NUM_STOPS 480
#define NUM_ROUTES 30
#define NUM_TILES 1
#define REFRESH_INTERVAL 20
#define TIMEOUT_INTERVAL 10.0
#define ENGLISH_UNIT
#define SUPPORT_CHECKIN FALSE // support the checkin feature

// Colors
#define COLOR_TABLE_VIEW_BG [UIColor colorWithRed:0.918 green:0.906 blue:0.906 alpha:1.0]
#define COLOR_TABLE_VIEW_SEPARATOR [UIColor colorWithRed:0.345 green:0.482 blue:0.580 alpha:0.25]
#define COLOR_TAB_BAR_BG [UIColor colorWithRed:0.0 green:0.42 blue:0.8 alpha:0.3]
#define COLOR_NAV_BAR_BG [UIColor colorWithRed:0.118 green:0.243 blue:0.357 alpha:1.0]

// API
#define API_BASE_URL @"http://hoosbus.appspot.com/v1"

// App settings
#define APP_SETTINGS_XML @"http://artisticfrog.com/cross_promote/hoosbus/app_settings.xml"
#define APP_SETTINGS_OS3_XML @"http://artisticfrog.com/cross_promote/hoosbus/app_settings_os3.xml"

#define AD_ZONE_1 1 // stations view, rail view
#define AD_ZONE_2 2 // routes view
#define AD_ZONE_3 3 // prediction view

//#define AD_FREE [AdWhirlManager testAdFree]
#define AD_FREE [AppSettings adFree]
// Remember to call [AdWhirlManager removeAds] to stop timers when we want to switch off ads

// Ad networks settings
#define ADWHIRL_API_KEY @"00e9827988454c9d8079529617fe540f"
#define ADMOB_APP_ID @"a14cee7368e76fb"
#define INMOBI_APP_ID @"4028cba630724cd90130a9788bd10134"

// Appirater
#define APP_NAME	@"HoosBus"
#define APP_ID 334856530

// Flurry
#define FLURRY_KEY @"HRQJ5Z5UC7TUEANL7UXE"

// Cross promotion
#define APP_LIST_XML @"http://artisticfrog.com/cross_promote/hoosbus/app_list.xml"

// FAQ, Blog
#define URL_FAQ @"http://artisticfrog.com/cross_promote/hoosbus/faq.xml"
#define URL_BLOG @"http://happenapps.tumblr.com"

// Twitter
#define OAUTH_CONSUMER_KEY @"4lz7dcG5YHDD8EJEi95okg"
#define OAUTH_CONSUMER_SECRET @"Af4Fp5s8cTzjgRpiOzddh0LeoCQg8NaDg6VdMC8Aw"
#define TWITTER_SHARE_MESSAGE @"I am using HoosBus to check bus arrival times for UTS and CTS routes! #UVA #Cville #iPhone #HoosBus http://goo.gl/B2J9T"

// Facebook
#define FB_API_KEY @"76d6e80d1aac383b41662c24bd69f2fc"
#define FB_API_SECRET @"077b7e9d722d7d7f4619c84b4ba69d4e"
#define FB_SHARE_MESSAGE @""
#define FB_SHARE_ATTACHMENT @"{\"name\":\"HoosBus\",\"href\":\"http://bit.ly/9iZokR\",\"description\":\"The must-have iPhone app for every bus rider in C'ville!\",\"media\":[{\"type\":\"image\",\"src\":\"http://artisticfrog.com/cross_promote/hoosbus/icon90.png\",\"href\":\"http://bit.ly/9iZokR\"}],\"properties\":{\"Download now for free\":{\"text\":\"iTunes App Store\",\"href\":\"http://bit.ly/9iZokR\"}}}"

// Email
#define STRING_EMAIL_SUBJECT @"Hey, check out HoosBus!"
#define STRING_EMAIL_BODY @"Hey!\n\nCheck out HoosBus, the must-have iPhone app for C'ville bus riders!\n\nDownload here for free:\nhttp://goo.gl/qQ1EJ\n\nHave a nice ride!"
