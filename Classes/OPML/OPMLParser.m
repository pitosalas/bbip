//
//  OPMLParser.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OPMLParser.h"
#import "OPMLGuide.h"
#import "OPMLFeed.h"

static NSString *ELEMENT_OUTLINE	= @"outline";
static NSString *ATTR_TYPE			= @"type";
static NSString *ATTR_TEXT			= @"text";
static NSString *ATTR_XML_URL		= @"xmlUrl";
static NSString *ATTR_HTML_URL		= @"htmlUrl";
static NSString *ATTR_READ_KEYS		= @"bb:readArticles";

@implementation OPMLParser

- (void)dealloc {
	[guides release];
	[super dealloc];
}

/**
 * Returns the list of OPMLGuide objects.
 */
- (NSArray *)parseURL:(NSURL *)url {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	
	[parser setDelegate:self];
	[parser parse];
	
	[parser release];
	
	return guides;
}

#pragma mark NSXMLParser delegate

/**
 * Document parsing has just begun.
 * Create new guides list.
 */
- (void)parserDidStartDocument:(NSXMLParser *)parser {
	[guides release];
	guides = [[NSMutableArray alloc] init];
	currentGuide = nil;
}

/**
 * New element found.
 * Can be guide or feed.
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName 
	attributes:(NSDictionary *)attributeDict {
	
	if ([qualifiedName isEqual:ELEMENT_OUTLINE]) {
		NSString *type = [attributeDict valueForKey:ATTR_TYPE];
		if ([type isEqual:@"rss"]) {
			[self parseFeed:attributeDict];
		} else {
			[self parseGuide:attributeDict];
		}
	}
}

/**
 * Parses feed attributes.
 */
- (void)parseFeed:(NSDictionary *)attributeDict {
	if (currentGuide == nil) return;
	
	OPMLFeed *feed = [[OPMLFeed alloc] initWithTitle:[attributeDict valueForKey:ATTR_TEXT]
											  xmlURL:[attributeDict valueForKey:ATTR_XML_URL]
											 htmlURL:[attributeDict valueForKey:ATTR_HTML_URL]
									 readArticleKeys:[self parseReadKeys:attributeDict]];
	[currentGuide addFeed:feed];
	[feed release];
}

/**
 * Parses guide attributes.
 */
- (void)parseGuide:(NSDictionary *)attributeDict {
}

/**
 * Parses read article keys.
 */
- (NSArray *)parseReadKeys:(NSDictionary *)attributeDict {
	NSString *keyString = [attributeDict valueForKey:ATTR_READ_KEYS];
	if (keyString == nil) return nil;
	
	return [keyString componentsSeparatedByString:@","];
}

@end
