//
//  MatchKeyCalculator.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 10/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MatchKeyCalculator.h"
#import "Constants.h"
#import "NSString+JavaHash.h"


@implementation MatchKeyCalculator

/**
 * Calculates the match code given all mentioned flags and values.
 */
+ (NSString *) calculateWithTitle:(NSString *)title 
						   link:(NSString *)link 
						pubDate:(NSDate *)pubDate
				   handlingType:(int)handlingType {

	NSString *matchKey = nil;
	
	if (handlingType == HTYPE_STANDARD) {
		matchKey = [MatchKeyCalculator calculateStandardWithTitle:title link:link];
	} else if (handlingType == HTYPE_WIKI) {
		matchKey = [MatchKeyCalculator calculateForWikiWithTitle:title link:link pubDate:pubDate];
	}
	
	return matchKey;
}

/**
 * Calculates standard match key.
 */
+ (NSString *) calculateStandardWithTitle:(NSString *)title link:(NSString *)link {
	long long code = link == nil ? 0 : abs([link javaHash]);
	code = code * 29L + (title == nil ? 0 : abs([title javaHash]));
	
	return [NSString stringWithFormat:@"%qx", code];
}

/**
 * Calculates Wiki / CMS match key.
 */
+ (NSString *) calculateForWikiWithTitle:(NSString *)title link:(NSString *)link pubDate:(NSDate *)pubDate {
	long long code = link == nil ? 0 : abs([link javaHash]);
	code = code * 29L + (title == nil ? 0 : abs([title javaHash]));
	code = code * 29L + (pubDate == nil ? 0 : [pubDate timeIntervalSince1970] * 1000L);

	return [NSString stringWithFormat:@"%qx", code];;
}

@end
