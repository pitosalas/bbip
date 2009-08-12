//
//  BBWebView.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBWebView : UIWebView {
	CGPoint		gestureStart;
	UIView		*touchesDelegate;
	BOOL		tracking;
	
	id			navDelegate;
}

@property (nonatomic, assign) id navDelegate;

@end
