//
//  BBWebView.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBWebView : UIWebView {
	UIView			*touchesDelegate;
	CGPoint			gestureStart;
	NSTimeInterval	touchStart;
	BOOL			tracking;
	
	id				navDelegate;
}

@property (nonatomic, assign) id navDelegate;

@end



@interface BBWebView (private)

/** Calls a delegate to switch articles. */
- (void)delegateArticleSwitching:(BOOL)previous;

@end
