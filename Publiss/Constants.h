//
//  Constants.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

static NSString *const PUBDownloadProgressNotification = @"PUBDownloadProgressNotification";
static NSString *const PUBDidFinishDownloadNotification = @"PUBDidFinishDownloadNotification";
static NSString *const PUB_NOTIFICATION_DOWNLOAD_STOPPED = @"DocumentLoading_Stopped_PUBDocumentFetcher";
static NSString *const PUB_NOTIFICATION_DOWNLOAD_CANCELLED = @"DocumentLoading_Cancelled_PUBPreviewViewController";
static NSString *const PUB_NOTIFICATION_UPDATE_CELL = @"Update_Cell_PUBCellView";
static NSString *const PUBUpdatePreviewNotification = @"PUBUpdatePreviewNotification";
static NSString *const PUB_NOTIFICATION_RELOAD_CELL = @"Reload_Cell_PUBPreviewViewController";
static NSString *const PUB_NOTIFICATION_DISMISS_POPOVER = @"Dismiss_Popover_PUPPreviewViewController";
static NSString *const PUB_NOTIFICATION_RELOAD_UI = @"Update_UI_PUBCellView";
static NSString *const PUBEnableUIInteractionNotification = @"PUBEnableUIInteractionNotification";

static NSString *const PUB_NOTIFICATION_APP_START = @"PUBNotification_App_Start";
static NSString *const PUB_NOTIFICATION_DOCUMENT_OPEN = @"PUBNotification_Document_Open";

// Statistic Keys
static NSString *const PUB_STATISTIC_APP_ID_KEY = @"device_identifier";
static NSString *const PUB_STATISTIC_DOCUMENT_ID_KEY = @"apple_product_id";
static NSString *const PUB_STATISTIC_TIMESTAMP_KEY = @"timestamp";
static NSString *const PUB_STATISTIC_EVENT_KEY = @"event";

// specifics keys
static NSString *const PUB_STATISTIC_EVENT_OPEN = @"open";
static NSString *const PUB_STATISTIC_EVENT_START = @"start";
static NSString *const PUB_STATISTIC_EVENT_PAGE = @"page";
static NSString *const PUB_STATISTIC_EVENT_READ = @"read";


// User defaults
static NSString *const PUB_USERDEFAULTS_STATISTIC = @"PUB_UserDefault_Stastic";

static NSString *const TITLE = @"Publiss";

// Availability Macros
#define PUB_IS_IPAD() UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
#define PUB_IS_IPHONE5() (([[UIScreen mainScreen] bounds].size.height - 568) ? NO : YES)
