//
//  RSSItemTests.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RSSItemTests.h"
#import "RSSItem.h"

@implementation RSSItemTests

- (void)setUp {
	item = [RSSItem new];
}

- (void)tearDown {
	[item release];
}

- (void)testDateConversions {
	NSDateFormatter *f = [[[NSDateFormatter alloc] init]  autorelease];
//	STAssertEqualObjects([self parseDate:@"Wed, 12 May 2004 07:20:13 EDT"], [f dateFromString:@"2004-05-12 14:20:13 +0300"], @"Wrong date");
	STAssertEqualObjects([self parseDate:@"2003-09-11T13:13-06:00"],		@"2003-09-11 22:13:00 +0300", @"Wrong date");
	STAssertEqualObjects([self parseDate:@"2006-08-22T08:21:00+05:30"],		@"2006-08-22 05:51:00 +0300", @"Wrong date");
	STAssertEqualObjects([self parseDate:@"2006-08-22T08:21:00+5:30"],		@"2006-08-22 05:51:00 +0300", @"Wrong date");
	STAssertEqualObjects([self parseDate:@"2006-08-22T08:21:00+0530"],		@"2006-08-22 05:51:00 +0300", @"Wrong date");
	STAssertEqualObjects([self parseDate:@"2006-08-22T07:15:12Z"],			@"2006-08-22 07:15:12 +0300", @"Wrong date");
}

- (NSString *)parseDate:(NSString *)date {
	return [NSString stringWithFormat:@"%@", [RSSItem dateFromString:date]];
}

@end
