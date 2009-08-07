//
//  RSSFeedParser.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RSSFeedParser.h"
#import "RSSItem.h"


@implementation RSSFeedParser

/** Parses the feed from the given URL and returns the array of items. */
- (NSArray *)parseFeedFromURL:(NSURL *)url {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	NSArray *items = [self parseFeedWithParser:parser];
	[parser release];
	
	return items;
}

/** Parses the feed from the given data and returns the array of items. */
- (NSArray *)parseFeedFromData:(NSData *)data {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	NSArray *items = [self parseFeedWithParser:parser];
	[parser release];
	
	return items;
}

#pragma mark -
#pragma mark Private

/** Parses the feed from a pre-initialized parser and returns the array of items. */
- (NSArray *)parseFeedWithParser:(NSXMLParser *)parser {
	
}

@end
