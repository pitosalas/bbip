//
//  RSSFeedParserTests.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RSSFeedParserTests.h"
#import "RSSFeedParser.h"
#import "AbstractParser.h"
#import "RSS091Parser.h"
#import "RSS10Parser.h"
#import "RSS20Parser.h"
#import "Atom03Parser.h"
#import "Atom10Parser.h"
#import "RSSItem.h"


@implementation RSSFeedParserTests

- (void)setUp {
	parser = [[RSSFeedParser alloc] init];
}

- (void)tearDown {
	[parser release];
}

#pragma mark -
#pragma mark Parser detection

- (void)testDetectingRSS091 {
	AbstractParser *p = [parser findParserForElement:@"rss" attributes:[NSDictionary dictionaryWithObject:@"0.91" forKey:@"version"]];
	STAssertEqualObjects([p class], [RSS091Parser class], @"Wrong parser type");
}

- (void)testDetectingRSS092 {
	AbstractParser *p = [parser findParserForElement:@"rss" attributes:[NSDictionary dictionaryWithObject:@"0.92" forKey:@"version"]];
	STAssertEqualObjects([p class], [RSS091Parser class], @"Wrong parser type");
}

- (void)testDetectingRSS093 {
	AbstractParser *p = [parser findParserForElement:@"rss" attributes:[NSDictionary dictionaryWithObject:@"0.93" forKey:@"version"]];
	STAssertEqualObjects([p class], [RSS091Parser class], @"Wrong parser type");
}

- (void)testDetectingRSS094 {
	AbstractParser *p = [parser findParserForElement:@"rss" attributes:[NSDictionary dictionaryWithObject:@"0.94" forKey:@"version"]];
	STAssertEqualObjects([p class], [RSS20Parser class], @"Wrong parser type");
}

- (void)testDetectingRDF {
	AbstractParser *p = [parser findParserForElement:@"rdf" attributes:nil];
	STAssertEqualObjects([p class], [RSS10Parser class], @"Wrong parser type");
}

- (void)testDetectingAtom03 {
	AbstractParser *p;

	p = [parser findParserForElement:@"feed" attributes:[NSDictionary dictionaryWithObject:@"0.1" forKey:@"version"]];
	STAssertEqualObjects([p class], [Atom03Parser class], @"Wrong parser type");

	p = [parser findParserForElement:@"feed" attributes:[NSDictionary dictionaryWithObject:@"0.2" forKey:@"version"]];
	STAssertEqualObjects([p class], [Atom03Parser class], @"Wrong parser type");
	
	p = [parser findParserForElement:@"feed" attributes:[NSDictionary dictionaryWithObject:@"0.3" forKey:@"version"]];
	STAssertEqualObjects([p class], [Atom03Parser class], @"Wrong parser type");
}

- (void)testDetectingAtom10 {
	AbstractParser *p;

	p = [parser findParserForElement:@"feed" attributes:nil];
	STAssertEqualObjects([p class], [Atom10Parser class], @"Wrong parser type");

	p = [parser findParserForElement:@"feed" attributes:[NSDictionary dictionaryWithObject:@"1.0" forKey:@"version"]];
	STAssertEqualObjects([p class], [Atom10Parser class], @"Wrong parser type");
}

#pragma mark -
#pragma mark Parsing sample feeds

- (void)testParsingSampleRSS091 {
	NSArray *items = [parser parseFeedFromData:[self fixtureData:@"rss-0.91"]];
	STAssertNotNil(items, @"Should return items");
	STAssertEquals((int)[items count], 6, @"Wrong number of items");
	
	// Item 1
	RSSItem *item = [items objectAtIndex:0];
	STAssertEqualObjects(item.title, @"Editors' Newswire for 12 April, 2002", @"Wrong title");
	STAssertEqualObjects(item.body,  @"Newswire stories, including: WSIO goes RAND?.", @"Wrong body");
	STAssertEqualObjects(item.url,   @"http://www.xmlhack.com/read.php?item=1613", @"Wrong link");
	STAssertNil(item.pubDate, @"Date wasn't given");

	// Item 2
	item = [items objectAtIndex:1];
	STAssertEqualObjects(item.title, @"Revised DOM Level 3 drafts", @"Wrong title");
	STAssertEqualObjects(item.body,  @"The W3C has released new draft of Document Object\n      Model (DOM) Level 3 Abstract Schemas and Load and Save\n      Specification and Document Object Model (DOM) Level 3 Core\n      Specification.", @"Wrong body");
	STAssertEqualObjects(item.url,   @"http://www.xmlhack.com/read.php?item=1612", @"Wrong link");
	STAssertNil(item.pubDate, @"Date wasn't given");
}

- (void)testParsingSampleRSS092 {
	NSArray *items = [parser parseFeedFromData:[self fixtureData:@"rss-0.92"]];
	STAssertNotNil(items, @"Should return items");
	STAssertEquals((int)[items count], 22, @"Wrong number of items");
	
	// Item 3
	RSSItem *item = [items objectAtIndex:2];
	STAssertNil(item.title,   @"Wrong title");
	STAssertEqualObjects(item.body,  @"<a href=\"http://arts.ucsc.edu/GDead/AGDL/other1.html\">The Other One</a>, live instrumental, One From The Vault. Very rhythmic very spacy, you can listen to it many times, and enjoy something new every time.", @"Wrong body");
	STAssertNil(item.url,     @"Wrong link");
	STAssertNil(item.pubDate, @"Date wasn't given");
}

- (void)testParsingSampleRSS10 {
	NSArray *items = [parser parseFeedFromData:[self fixtureData:@"rss-1.0"]];
	STAssertNotNil(items, @"Should return items");
	STAssertEquals((int)[items count], 15, @"Wrong number of items");
	
	// Item 0 -- All fields, description before content:encoded
	RSSItem *item = [items objectAtIndex:0];
	STAssertEqualObjects(item.title,	@"Related Searches", @"Wrong title");
	STAssertEqualObjects(item.body,		@"<p>Google is testing a new feature that suggests related searches (<a href=\"http://www.haymeadows.com/related.htm\">screenshot</a>). The <em>something different</em> link apparently suggests a whole new batch of related searches. </p>", @"Wrong body");
	STAssertEqualObjects(item.url,		@"http://google.blogspace.com/archives/001033", @"Wrong link");
	STAssertEqualObjects(item.pubDate,	@"2003-09-11T13:13-06:00", @"Wrong date");

	// Item 1 -- Description only
	item = [items objectAtIndex:1];
	STAssertEqualObjects(item.title,	@"Froogle Redesign", @"Wrong title");
	STAssertEqualObjects(item.body,		@"Google's product search, Froogle has redesigned. New features include: sort by price, Grid View (the page becomes a grid of product images, just like Google Image Search), and a sidebar to make more advanced searching easier....", @"Wrong body");
	STAssertEqualObjects(item.url,		@"http://google.blogspace.com/archives/001032", @"Wrong link");
	STAssertEqualObjects(item.pubDate,	@"2003-09-08T13:21-06:00", @"Wrong date");
	
	// Item 2 -- Content:encoded only
	item = [items objectAtIndex:2];
	STAssertEqualObjects(item.title,	@"New Toolbar, Ad Sizes", @"Wrong title");
	STAssertEqualObjects(item.body,		@"<p>Google has released <a href=\"http://toolbar.google.com\">Google Toolbar 2.0</a> which has several interesting new features including a BlogThis button, a pop-up blocker, and AutoFill. It's interesting to see that Google is providing more generic Web utilities and less Google-specific stuff. I guess now that Microsoft has announced they won't continue to update Internet Explorer, it's up to Google to provide these important features.</p>\n\n<p>Meanwhile, Google AdSense has introduced two new ad sizes (<a href=\"http://www.google.com/adsense/adformats\">available now</a>): horizontal leaderboard (728x90) and inline rectangle (300x250).</p>", @"Wrong body");
	STAssertEqualObjects(item.url,		@"http://google.blogspace.com/archives/001029", @"Wrong link");
	STAssertEqualObjects(item.pubDate,	@"2003-08-22T15:23-06:00", @"Wrong date");

	// Item 3 -- Content:encoded before description only
	item = [items objectAtIndex:3];
	STAssertEqualObjects(item.title,	@"Web Calc", @"Wrong title");
	STAssertEqualObjects(item.body,		@"<p>Google now has <a href=\"http://www.google.com/help/features.html#calculator\">a built in calculator</a> that can tell you everything from <a href=\"http://www.google.com/search?q=2%2B2\">2+2</a> to <a href=\"http://www.google.com/search?q=speed+of+light+in+furlongs+per+fortnight\">speed of light in furlongs per fortnight</a> to <a href=\"http://www.google.com/search?q=2048+in+binary\">2048 in binary</a>.</p>\n\n<p>I'd love to know who did this. Awesome hack!</p>\n\n<p>Now what would be really cool: Google API support for this.</p>", @"Wrong body");
	STAssertEqualObjects(item.url,		@"http://google.blogspace.com/archives/001023", @"Wrong link");
	STAssertEqualObjects(item.pubDate,	@"2003-08-12T17:43-06:00", @"Wrong date");	
}

- (void)testParsingSampleRSS20ContentEncoded {
	NSArray *items = [parser parseFeedFromData:[self fixtureData:@"rss-2.0-1"]];
	STAssertNotNil(items, @"Should return items");
	STAssertEquals((int)[items count], 3, @"Wrong number of items");
	
	// Item 0
	RSSItem *item = [items objectAtIndex:0];
	STAssertEqualObjects(item.title,	@"Test 1", @"Wrong title");
	STAssertEqualObjects(item.body,		@"1&amp;", @"Wrong body");
	STAssertEqualObjects(item.url,		nil, @"Wrong link");
	STAssertEqualObjects(item.pubDate,	@"Wed, 12 May 2004 07:20:13 EDT", @"Wrong date");
	
	// Item 1
	item = [items objectAtIndex:1];
	STAssertEqualObjects(item.title,	@"Test 2", @"Wrong title");
	STAssertEqualObjects(item.body,		@"2", @"Wrong body");
	STAssertEqualObjects(item.url,		nil, @"Wrong link");
	STAssertEqualObjects(item.pubDate,	@"Wed, 12 May 2004 07:20:13 EDT", @"Wrong date");
	
	// Item 2
	item = [items objectAtIndex:2];
	STAssertEqualObjects(item.title,	@"Test 3", @"Wrong title");
	STAssertEqualObjects(item.body,		@"3&", @"Wrong body");
	STAssertEqualObjects(item.url,		nil, @"Wrong link");
	STAssertEqualObjects(item.pubDate,	@"Wed, 12 May 2004 07:20:13 EDT", @"Wrong date");
}

- (void)testParsingSampleRSS20 {
	NSArray *items = [parser parseFeedFromData:[self fixtureData:@"rss-2.0-2"]];
	STAssertNotNil(items, @"Should return items");
	STAssertEquals((int)[items count], 15, @"Wrong number of items");
	
	// Item 0
	RSSItem *item = [items objectAtIndex:0];
	STAssertEqualObjects(item.title,	@"Recent Wiki spam attacks", @"Wrong title");
	STAssertEqualObjects(item.body,		@"                             <p />\nTwo Wiki spammers have been trying for over a week to sneak links into the <a href=\"http://www.rollerweblogger.org/wiki\">Roller Wiki</a>. I subscribe to the Wiki's Recent Changes newsfeed, so I am able to catch them everytime, but I am getting a little tired of doing this.  One Wiki spammer has the IP address 222.64.23.78 and is advertising the site <span style=\"color:blue\">http://www.newline.sh.cn</span>.  The other Wiki spammer has the IP address 61.149.181.4 and is advertising <span style=\"color:blue\">http://www.99986.com</span>. I would hate to have to set usernames and passwords for the Wiki again, but these dirtbags may force me to do it.\n         ", @"Wrong body");
	STAssertEqualObjects(item.url,		@"http://www.rollerweblogger.org/page/roller/20040512#recent_wiki_spam_attacks", @"Wrong link");
	STAssertEqualObjects(item.pubDate,	@"Wed, 12 May 2004 07:20:13 EDT", @"Wrong date");

	// Item 1 - Guid is not permalink
	item = [items objectAtIndex:1];
	STAssertEqualObjects(item.url,		nil, @"Wrong link");

	// Item 1 - Guid has priority over link tag
	item = [items objectAtIndex:2];
	STAssertEqualObjects(item.url,		@"http://www.rollerweblogger.org/page/roller/20040509#what_belongs_on_a_corporate", @"Wrong link");
}

- (void)testParsingSampleAtom03 {
	NSArray *items = [parser parseFeedFromData:[self fixtureData:@"atom-0.3"]];
	STAssertNotNil(items, @"Should return items");
	STAssertEquals((int)[items count], 10, @"Wrong number of items");
	
	// Item 0
	RSSItem *item = [items objectAtIndex:0];
	STAssertEqualObjects(item.title,	@"Shouldn't this be reason enough to opt for an Open Source development model?", @"Wrong title");
	STAssertEqualObjects(item.body,		@"In a traditional software development model, the client asks for one thing and is delivered something else not to say anything about the galloping costs involved as is rightly illustrated by the cartoon below.\n\nFig : Traditional software development model  (original link)\n\nShouldn't it be reason enough to take a long hard look at the development model of open source software instead of sticking to", @"Wrong body");
	STAssertEqualObjects(item.url,		@"http://linuxhelp.blogspot.com/2006/08/shouldnt-this-be-reason-enough-to-opt.html", @"Wrong link");
	STAssertEqualObjects(item.pubDate,	@"2006-08-22T07:15:12Z", @"Wrong date");
}

- (void)testParsingSampleAtom10 {
	NSArray *items = [parser parseFeedFromData:[self fixtureData:@"atom-1.0"]];
	STAssertNotNil(items, @"Should return items");
	STAssertEquals((int)[items count], 25, @"Wrong number of items");
	
	// Item 0
	RSSItem *item = [items objectAtIndex:0];
	STAssertEqualObjects(item.title,	@"mysql partitioning", @"Wrong title");
	STAssertEqualObjects(item.body,		@"Table partitioning is a concept which allows data to be stored in multiple locations on one or more disks and access to the data is through SQL queries. The way data is stored and retrieved is invisible to the end user. \n\nMysql allows the user to select the rules based on which data would be spread over multiple partitions in a table. Mysql supports horizontab partitioning whereby the rows of a ", @"Wrong body");
	STAssertEqualObjects(item.url,		@"http://jayant7k.blogspot.com/2006/08/mysql-partitioning.html", @"Wrong link");
	STAssertEqualObjects(item.pubDate,	@"2006-08-17T17:07:28.356-08:00", @"Wrong date");
}

/** Returns the data object filled with the context of the fixture. */
- (NSData *)fixtureData:(NSString *)name {
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:@"xml"];
	STAssertNotNil(path, @"Fixture path wasn't found");
	
	NSData *data = [NSData dataWithContentsOfFile:path];
	STAssertNotNil(data, @"Fixture data wasn't found");
	
	return data;
}

@end
