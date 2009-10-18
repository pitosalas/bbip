//
//  MatchKeyCalculatorTest.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 10/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MatchKeyCalculatorTest.h"


@implementation MatchKeyCalculatorTest

- (void) testStandard {
	NSString *key;
	
	key = [MatchKeyCalculator calculateStandardWithTitle:nil link:nil];
	STAssertEqualObjects(key, @"0", @"Wrong key code");

	key = [MatchKeyCalculator calculateStandardWithTitle:@"Some article title" link:nil];
	STAssertEqualObjects(key, @"2b551ca2", @"Wrong key code");

	key = [MatchKeyCalculator calculateStandardWithTitle:nil link:@"http://some.com/article.html"];
	STAssertEqualObjects(key, @"a3dd0cbeb", @"Wrong key code");
	
	key = [MatchKeyCalculator calculateStandardWithTitle:@"Some article title" link:@"http://some.com/article.html"];
	STAssertEqualObjects(key, @"a6925e88d", @"Wrong key code");
}

- (void) testWiki {
	NSString *key;
	
	NSDateFormatter *df = [[NSDateFormatter new] autorelease];
	[df setDateStyle:NSDateFormatterMediumStyle];
	[df setTimeStyle:NSDateFormatterNoStyle];

	NSDate *date = [df dateFromString:@"Jan 01, 2009"];
	
	key = [MatchKeyCalculator calculateForWikiWithTitle:nil link:nil pubDate:nil];
	STAssertEqualObjects(key, @"0", @"Wrong key code");
	
	key = [MatchKeyCalculator calculateForWikiWithTitle:@"Some article title" link:nil pubDate:nil];
	STAssertEqualObjects(key, @"4e8a43e5a", @"Wrong key code");
	
	key = [MatchKeyCalculator calculateForWikiWithTitle:nil link:@"http://some.com/article.html" pubDate:nil];
	STAssertEqualObjects(key, @"12900a7199f", @"Wrong key code");

	key = [MatchKeyCalculator calculateForWikiWithTitle:@"Some article title" link:@"http://some.com/article.html" pubDate:date];
	STAssertEqualObjects(key, @"24c785ac6f9", @"Wrong key code");
}


@end
