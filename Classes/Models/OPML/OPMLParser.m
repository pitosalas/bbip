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
static NSString *ATTR_TITLE			= @"title";
static NSString *ATTR_XML_URL		= @"xmlUrl";
static NSString *ATTR_HTML_URL		= @"htmlUrl";
static NSString *ATTR_READ_KEYS		= @"bb:readArticles";
static NSString *ATTR_ICON			= @"bb:icon";

@implementation OPMLParser

- (void)dealloc {
	[guides release];
	[super dealloc];
}

/**
 * Returns the list of OPMLGuide objects.
 */
- (NSArray *)parseURL:(NSURL *)url {
	return [self parse:[[NSXMLParser alloc] initWithContentsOfURL:url]];
}

/**
 * Returns the list of OPMLGuide objects.
 */
- (NSArray *)parseString:(NSString *)opml {
	return [self parse:[[NSXMLParser alloc] initWithData:[opml dataUsingEncoding:NSUTF8StringEncoding]]];
}

- (NSArray *)parse:(NSXMLParser *)parser {
	[parser setShouldProcessNamespaces:YES];
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
			if (currentGuide != nil) {
				OPMLFeed *feed = [self parseFeed:attributeDict];
				if (feed != nil) [currentGuide addFeed:feed];
			}
		} else {
			currentGuide = [self parseGuide:attributeDict];
			if (currentGuide != nil) [guides addObject:currentGuide];
		}
	}
}

/**
 * Parses feed attributes.
 */
- (OPMLFeed *)parseFeed:(NSDictionary *)attributeDict {
	NSString *title = [attributeDict valueForKey:ATTR_TEXT];
	if (title == nil) title = [attributeDict valueForKey:ATTR_TITLE];
	
	OPMLFeed *feed = [[OPMLFeed alloc] initWithTitle:title
											  xmlURL:[attributeDict valueForKey:ATTR_XML_URL]
											 htmlURL:[attributeDict valueForKey:ATTR_HTML_URL]
									 readArticleKeys:[self parseReadKeys:attributeDict]];
	return [feed autorelease];
}

/**
 * Parses guide attributes.
 */
- (OPMLGuide *)parseGuide:(NSDictionary *)attributeDict {
	OPMLGuide *guide = [[OPMLGuide alloc] initWithName:[attributeDict valueForKey:ATTR_TEXT]
											  iconName:[attributeDict valueForKey:ATTR_ICON]];
	return [guide autorelease];
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
