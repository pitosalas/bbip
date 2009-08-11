//
//  RSSFeedParser.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RSSFeedParser.h"
#import "RSSItem.h"
#import "AbstractParser.h"
#import "RSS091Parser.h"
#import "RSS10Parser.h"
#import "RSS20Parser.h"
#import "Atom03Parser.h"
#import "Atom10Parser.h"

@implementation RSSFeedParser

@synthesize delegate;

- (void)dealloc {
	self.delegate = nil;
	[super dealloc];
}

/** Parses the feed from the given URL and returns the array of items. */
- (NSArray *)parseFeedFromURL:(NSURL *)url {
	NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
	NSError* error;
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];

	return [self parseFeedFromData:data];
}

/** Parses the feed from the given data and returns the array of items. */
- (NSArray *)parseFeedFromData:(NSData *)data {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	NSArray *items = [self parseFeedWithParser:parser];
	[parser release];
	
	return items;
}

#pragma mark -
#pragma mark Parsing

/** Parses the feed from a pre-initialized parser and returns the array of items. */
- (NSArray *)parseFeedWithParser:(NSXMLParser *)parser {
	[parser setShouldProcessNamespaces:YES];
	[parser setDelegate:self];
	[parser parse];
	return self.delegate ? self.delegate.items : nil;
}

/** Document parsing has just begun. */
- (void)parserDidStartDocument:(NSXMLParser *)parser {
	self.delegate = nil;
}

/** New element found. */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName 
	attributes:(NSDictionary *)attributeDict {

	if (self.delegate == nil) {
		self.delegate = [self findParserForElement:elementName attributes:attributeDict];
		if (self.delegate == nil) [parser abortParsing];
	} else {
		[self.delegate parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];
	}
}


/** Invoked by the parser when the closing element is found. */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName {
	
	[self.delegate parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName];
}

/** Invoked when characters found inside the current element. Can be invoked multiple times. */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[self.delegate parser:parser foundCharacters:string];
}

/** Invoked when CDATA block is found. */
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
	[self.delegate parser:parser foundCDATA:CDATABlock];
}

/** Finds a parser for the given root element. */
- (AbstractParser *)findParserForElement:(NSString *)elementName attributes:(NSDictionary *)attributeDict {
	if ([@"rss" caseInsensitiveCompare:elementName] == NSOrderedSame) {
		NSString *version = [attributeDict valueForKey:@"version"];
		if ([version isEqual:@"0.91"] || [version isEqual:@"0.92"] || [version isEqual:@"0.93"]) {
			return [[RSS091Parser new] autorelease];
		} else if ([version isEqual:@"0.94"] || [version isEqual:@"2.0"]) {
			return [[RSS20Parser new] autorelease];
		}
	} else if ([@"rdf" caseInsensitiveCompare:elementName] == NSOrderedSame) {
		return [[RSS10Parser new] autorelease];
	} else if ([@"feed" caseInsensitiveCompare:elementName] == NSOrderedSame) {
		NSString *version = [attributeDict valueForKey:@"version"];
		if ([version isEqual:@"0.1"] || [version isEqual:@"0.2"] || [version isEqual:@"0.3"]) {
			return [[Atom03Parser new] autorelease];
		} else {
			return [[Atom10Parser new] autorelease];
		}
	}
	
	return nil;
}
	
@end
