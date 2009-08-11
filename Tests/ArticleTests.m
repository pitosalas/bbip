//
//  ArticleTests.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ArticleTests.h"


@implementation ArticleTests

- (void)testHTMLToPlain {
	STAssertEqualObjects([Article plainTextFromHTML:@"<p>Hello, <i>World<b>!</b></p>"], @"Hello, World!", @"Wrong conversion");
}

- (void)testSentencesFromText {
	NSString *result;
	
	result = [Article sentencesFromText:@"First.Second! Third? Forth. Fifth!" sentences:3];
	STAssertEqualObjects(result, @"First.Second! Third?", @"Wrong");

	result = [Article sentencesFromText:@"First.Second! " sentences:3];
	STAssertEqualObjects(result, @"First.Second! ", @"Wrong");

	result = [Article sentencesFromText:@"" sentences:3];
	STAssertEqualObjects(result, @"", @"Wrong");
	
	result = [Article sentencesFromText:@" ABC " sentences:3];
	STAssertEqualObjects(result, @" ABC ", @"Wrong");
}

@end