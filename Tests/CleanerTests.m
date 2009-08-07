//
//  CleanerTests.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CleanerTests.h"
#import "Cleaner.h"

@implementation CleanerTests

- (void)testBorderArticleDates {
	Cleaner *cleaner = [self cleanerWithRead:60 andUnread:120];
	NSDate *rdate = [cleaner borderReadArticleDate];
	NSDate *udate = [cleaner borderUnreadArticleDate];
	
	STAssertEquals((int)[rdate timeIntervalSinceNow], -60,  @"Wrong interval");
	STAssertEquals((int)[udate timeIntervalSinceNow], -120, @"Wrong interval");
}

- (Cleaner *)cleanerWithRead:(NSTimeInterval)read andUnread:(NSTimeInterval)unread {
	NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:60],  KEY_MAX_READ_AGE,
							  [NSNumber numberWithInt:120], KEY_MAX_UNREAD_AGE, nil];
	return [[[Cleaner alloc] initWithManagedObjectContext:nil defaults:defaults] autorelease];
}

@end
