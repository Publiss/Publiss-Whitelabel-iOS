//
//  PUBConstants.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#define PUBClearAllFilesOnAppStart 0 // Clear all downloaded files on app start.

//PUbliss Website
static NSString *const PUBWebsiteURL = @"http://www.publiss.com";

static NSString *const PUBDownloadProgressNotification = @"PUBDownloadProgressNotification";
static NSString *const PUBDidFinishDownloadNotification = @"PUBDidFinishDownloadNotification";
static NSString *const PUB_NOTIFICATION_UPDATE_CELL = @"Update_Cell_PUBCellView";
static NSString *const PUBUpdatePreviewNotification = @"PUBUpdatePreviewNotification";
static NSString *const PUB_NOTIFICATION_RELOAD_CELL = @"Reload_Cell_PUBPreviewViewController";
static NSString *const PUB_NOTIFICATION_DISMISS_POPOVER = @"Dismiss_Popover_PUPPreviewViewController";
static NSString *const PUB_NOTIFICATION_RELOAD_UI = @"Update_UI_PUBCellView";
static NSString *const PUBDocumentDownloadFinished = @"PUBDocumentDownloadFinished";

static NSString *const PUBApplicationDidStartNotification = @"PUBApplicationDidStartNotification";
static NSString *const PUBDocumentDidOpenNotification = @"PUBDocumentDidOpenNotification";
static NSString *const PUBDocumentDownloadNotification = @"PUBDocumentDownloadNotification";
static NSString *const PUBDocumentPageTrackedNotification = @"PUBDocumentPageTracked";
static NSString *const PUBDocumentPurchaseFinishedNotification = @"PUBDocumentPurchaseFinishedNotification";
static NSString *const PUBDocumentPurchaseUIUpdateNotification = @"PUBDocumentPurchaseUIUpdateNotification";
static NSString *const PUBDocumentFetcherUpdateNotification = @"PUBDocumentFetcherUpdateNotification";
static NSString *const PUBStatisticsDocumentDeletedNotification = @"PUBStatisticsDocumentDeletedNotification";

// Cell Notifications
static NSString *const PUBDeleteDocumentNotification = @"PUBDeleteDocumentNotification";

// Statistic Keys
static NSString *const PUBStatisticsAppIDKey = @"device_identifier";
static NSString *const PUBStatisticsDocumentIDKey = @"apple_product_id";
static NSString *const PUBStatisticsTimestampKey = @"timestamp";
static NSString *const PUBStatisticsEventTrackedPageKey = @"tracked_page_number";
static NSString *const PUBStatisticsEventKey = @"event";
static NSString *const PUBStatisticsUserDefaultsKey = @"PUBStatisticsUserDefaultsKey";

// notfification statistic keys
static NSString *const PUBStatisticsEventOpenKey = @"open";
static NSString *const PUBStatisticsEventStartKey = @"start";
static NSString *const PUBStatisticsEventPageKey = @"page";
static NSString *const PUBStatisticsEventReadKey = @"read";
static NSString *const PUBStatisticsEventDownloadKey = @"download";
static NSString *const PUBStatisticsPageDurationKey = @"duration";
static NSString *const PUBStatisticsDeviceIDKey = @"device";
static NSString *const PUBStatisticsiOSVersionKey = @"ios_version";
static NSString *const PUBStatisticsDeletedKey = @"delete";

// response objects
static NSString *const PUBJSONAppSecretKey = @"app_secret";
static NSString *const PUBJSONAppTokenKey = @"app_token";
static NSString *const PUBJSONSecret = @"secret";

// Core data
static NSString *const SortOrder = @"priority";

// iAP
static NSString *const PUBProductID = @"product_id";
static NSString *const PUBReceiptData = @"receipt_data";
static NSString *const PUBAPPToken = @"app_token";
static NSString *const PUBiAPSecrets = @"purchase_secrets";

// UI Stuff
static NSString *const PurchasingMenuStyle = @"PurchasingMenuStyle";
static NSString *const PurchasedMenuStyle = @"PurchasedMenuStyle";

//
static CGFloat const DURATION_PRESENT = .35f;
static CGFloat const DURATION_DISMISS = .30f;

// Availability Macros
#define PUBIsiPad() UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
#define PUBIsiPhone5() (([[UIScreen mainScreen] bounds].size.height - 568) ? NO : YES)

// Cast Helper
extern id PUBSafeCast(id object, Class targetClass);

// Version String
extern NSString *PUBVersionString();

// Logging
typedef NS_ENUM(NSUInteger, PUBLogLevelMask) {
    PUBLogLevelMaskNothing  = 0,
    PUBLogLevelMaskError    = 1 << 0,
    PUBLogLevelMaskWarning  = 1 << 1,
    PUBLogLevelMaskInfo     = 1 << 2,
    PUBLogLevelMaskVerbose  = 1 << 3,
    PUBLogLevelMaskAll      = UINT_MAX
};
static PUBLogLevelMask PUBLogLevel = PUBLogLevelMaskInfo|PUBLogLevelMaskWarning|PUBLogLevelMaskError;

#define PUBLogVerbose(fmt, ...) do { if (PUBLogLevel & PUBLogLevelMaskVerbose) NSLog((@"%s/%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }while(0)
#define PUBLog(fmt, ...) do { if (PUBLogLevel & PUBLogLevelMaskInfo) NSLog((@"%s/%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }while(0)
#define PUBLogWarning(fmt, ...) do { if (PUBLogLevel & PUBLogLevelMaskWarning) NSLog((@"Warning: %s/%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }while(0)
#define PUBLogError(fmt, ...) do { if (PUBLogLevel & PUBLogLevelMaskError) NSLog((@"Error: %s/%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }while(0)

// A better assert. NSAssert is too runtime dependent, and assert() doesn't log.
// http://www.mikeash.com/pyblog/friday-qa-2014-05-03-proper-use-of-asserts.html
// Accepts both:
// - PUBAssert(x > 0);
// - PUBAssert(y > 3, @"Bad value for y");
#define PUBAssert(expression, ...) \
do { if(!(expression)) { \
NSLog(@"%@", [NSString stringWithFormat: @"Assertion failure: %s in %s on line %s:%d. %@", #expression, __PRETTY_FUNCTION__, __FILE__, __LINE__, [NSString stringWithFormat:@"" __VA_ARGS__]]); \
abort(); }} while(0)

void PUBAssertIfNotMainThread(void);
