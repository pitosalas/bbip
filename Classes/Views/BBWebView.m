//
//  BBWebView.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBWebView.h"
#import "Constants.h"

const float kMinimumGestureLength = 25;
const float kMaximumVariance = 5;

@implementation BBWebView

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
	if (tracking) {
		UITouch *touch = [touches anyObject];
		CGPoint currentPosition = [touch locationInView:self];
		
		CGFloat deltaX = fabsf(gestureStart.x - currentPosition.x);
		CGFloat deltaY = fabsf(gestureStart.y - currentPosition.y);
		
		if (deltaX >= kMinimumGestureLength && deltaY <= kMaximumVariance) {
			// handle horizontal swipe
			
			NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
			
			if (gestureStart.x < currentPosition.x) {
				[nc postNotificationName:BBNotificationNextArticle object:self userInfo:nil];
			} else {
				[nc postNotificationName:BBNotificationPreviousArticle object:self userInfo:nil];
			}
			
			tracking = NO;
		} else if (deltaY >= kMinimumGestureLength && deltaX <= kMaximumVariance) {
			// handle vertical swipe
		}
	}
	
	[touchesDelegate					touchesMoved:touches withEvent:event];
	[[touchesDelegate nextResponder]	touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
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
