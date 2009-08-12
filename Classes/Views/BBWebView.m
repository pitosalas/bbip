//
//  BBWebView.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBWebView.h"
#import "Constants.h"

const float kMinimumGestureLength	= 25;
const float kMaximumVariance		= 5;
const float kMaximumTouchDistance	= 5;

@implementation BBWebView

@synthesize navDelegate;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	touchesDelegate = [super hitTest:point withEvent:event];
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	gestureStart = [touch locationInView:self];
	tracking = YES;
	
	[touchesDelegate					touchesBegan:touches withEvent:event];
	[[touchesDelegate nextResponder]	touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (tracking && navDelegate != nil) {
		UITouch *touch = [touches anyObject];
		CGPoint currentPosition = [touch locationInView:self];
		
		CGFloat deltaX = fabsf(gestureStart.x - currentPosition.x);
		CGFloat deltaY = fabsf(gestureStart.y - currentPosition.y);
		
		if (deltaX >= kMinimumGestureLength && deltaY <= kMaximumVariance) {
			// handle horizontal swipe
			
			SEL action;
			if (gestureStart.x < currentPosition.x) {
				action = @selector(onPreviousArticle);
			} else {
				action = @selector(onNextArticle);
			}
			
			if ([navDelegate respondsToSelector:action]) [navDelegate performSelector:action];
			
			tracking = NO;
		} else if (deltaY >= kMinimumGestureLength && deltaX <= kMaximumVariance) {
			// handle vertical swipe
		}
	}
	
	[touchesDelegate					touchesMoved:touches withEvent:event];
	[[touchesDelegate nextResponder]	touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	// See if we still tracking -- not processed a swipe yet
	if (tracking) {
		UITouch *touch = [touches anyObject];
		CGPoint currentPosition = [touch locationInView:self];
		
		CGFloat deltaX = fabsf(gestureStart.x - currentPosition.x);
		CGFloat deltaY = fabsf(gestureStart.y - currentPosition.y);

		if (deltaX < kMaximumTouchDistance && deltaY < kMaximumTouchDistance) {
			SEL action = @selector(onTouch);
			if ([navDelegate respondsToSelector:action]) [navDelegate performSelector:action];
		}
	}
	
	tracking = NO;

	[touchesDelegate					touchesEnded:touches withEvent:event];
	[[touchesDelegate nextResponder]	touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	tracking = NO;

	[touchesDelegate					touchesCancelled:touches withEvent:event];
	[[touchesDelegate nextResponder]	touchesCancelled:touches withEvent:event];
}

@end
