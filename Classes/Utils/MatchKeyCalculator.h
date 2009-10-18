//
//  MatchKeyCalculator.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 10/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"


@interface MatchKeyCalculator : NSObject {
}

/**
 * Calculates the match code given all mentioned flags and values.
 */
+ (NSString *) calculateWithTitle:(NSString *)title 
						   link:(NSString *)link 
						pubDate:(NSDate *)pubDate
				   handlingType:(int)handlingType;
																										
/**
 * Calculates standard match key.
 */
+ (NSString *) calculateStandardWithTitle:(NSString *)title link:(NSString *)link;

/**
 * Calculates Wiki / CMS match key.
 */
+ (NSString *) calculateForWikiWithTitle:(NSString *)title link:(NSString *)link pubDate:(NSDate *)pubDate;

@end
