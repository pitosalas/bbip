//
//  Constants.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** Settings */
extern NSString * const BBSettingCurrentFontBias;
extern NSString * const BBSettingReadArticleAge;
extern NSString * const BBSettingUnreadArticleAge;
extern NSString * const BBSettingDefaultOpmlUrl;
extern NSString * const BBSettingSelectedGuide;
extern NSString * const BBSettingUpdatePeriod;
extern NSString * const BBSettingAccountEmail;
extern NSString * const BBSettingAccountPassword;

/** Notifications */
extern NSString * const BBNotificationArticlesAdded;
extern NSString * const BBNotificationArticleRead;
extern NSString * const BBNotificationReachability;

/** Article cell */
extern float	  const BBArticleCellTextFontSize;
extern float	  const BBArticleCellDetailFontSize;

/** Handling types */
extern int		  const HTYPE_STANDARD;
extern int		  const HTYPE_WIKI;