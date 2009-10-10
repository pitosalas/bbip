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
	STAssertEquals([self parseDate:@"Wed, 12 May 2004 07:20:13 EDT"],	1084360813.0, @"Wrong date");
	STAssertEquals([self parseDate:@"2003-09-11T13:13-06:00"],			1063307580.0, @"Wrong date");
	STAssertEquals([self parseDate:@"2006-08-22T08:21:00+05:30"],		1156215060.0, @"Wrong date");
	STAssertEquals([self parseDate:@"2006-08-22T08:21:00+5:30"],		1156215060.0, @"Wrong date");
	STAssertEquals([self parseDate:@"2006-08-22T08:21:00+0530"],		1156215060.0, @"Wrong date");
	STAssertEquals([self parseDate:@"2006-08-22T07:15:12Z"],			1156220112.0, @"Wrong date");
}

- (NSTimeInterval)parseDate:(NSString *)date {
	return [[RSSItem dateFromString:date] timeIntervalSince1970];
}

@end
