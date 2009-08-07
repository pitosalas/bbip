//
//  OPMLParserTests.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OPMLParserTests.h"
#import "OPMLFeed.h"
#import "OPMLGuide.h"
#import "OPMLParser.h"

@implementation OPMLParserTests

- (void)setUp {
	parser = [[OPMLParser alloc] init];
}

- (void)tearDown {
	[parser release];
}

- (void)testParseReadKeys {
	NSDictionary *attrs = [NSDictionary dictionaryWithObject:@"a,b,c" forKey:@"bb:readArticles"];
	NSArray *keys = [parser parseReadKeys:attrs];

	STAssertEquals(3, (int)[keys count], @"Should include all 3 keys");
	STAssertEqualObjects(@"a", [keys objectAtIndex:0], @"Wrong key");
	STAssertEqualObjects(@"b", [keys objectAtIndex:1], @"Wrong key");
	STAssertEqualObjects(@"c", [keys objectAtIndex:2], @"Wrong key");
}

#pragma mark Feeds

- (void)testParseFeedFull {
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"rss",   @"type",
						   @"title", @"text",
						   @"a,b,c", @"bb:readArticles",
						   @"xml",   @"xmlUrl",
						   @"html",  @"htmlUrl",
						   nil];

	NSArray *keys  = [NSArray arrayWithObjects:@"a", @"b", @"c", nil];
	OPMLFeed *feed = [parser parseFeed:attrs];

	STAssertEqualObjects(feed.title, @"title", @"Wrong title");
	STAssertEqualObjects(feed.xmlURL, @"xml", @"Wrong XML URL");
	STAssertEqualObjects(feed.htmlURL, @"html", @"Wrong HTML URL");
	STAssertEqualObjects(feed.readArticleKeys, keys, @"Wrong keys");
}

- (void)testParseFeedNoKeys {
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"rss",   @"type",
						   @"title", @"text",
						   @"xml",   @"xmlUrl",
						   @"html",  @"htmlUrl",
						   nil];

	OPMLFeed *feed = [parser parseFeed:attrs];
	
	STAssertNil(feed.readArticleKeys, @"Wrong keys");
}

- (void)testParseFeedAlternativeTitle {
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"rss",   @"type",
						   @"title", @"title",
						   @"xml",   @"xmlUrl",
						   @"html",  @"htmlUrl",
						   nil];
	
	OPMLFeed *feed = [parser parseFeed:attrs];
	STAssertEqualObjects(feed.title, @"title", @"Wrong title");
}


#pragma mark Guides

- (void)testParseGuide {
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"title", @"text",
						   @"icon",  @"bb:icon",
						   nil];

	OPMLGuide *guide = [parser parseGuide:attrs];
	
	STAssertEqualObjects(guide.name, @"title", @"Wrong title");
	STAssertEqualObjects(guide.iconName, @"icon", @"Wrong icon");
}

#pragma mark Composite

- (void)testOPMLParsing {
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"sample" ofType:@"opml"];
	NSString *opml = [NSString stringWithContentsOfFile:path];

	NSArray *guides = [parser parseString:opml];
	
	STAssertEquals((int)[guides count], 2, @"Only two guides in the file");
	
}

@end
