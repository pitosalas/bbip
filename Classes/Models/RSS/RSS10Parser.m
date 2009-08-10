//
//  RSS10Parser.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RSS10Parser.h"
#import "RSSItem.h"

@implementation RSS10Parser

- (id)init {
	if (self = [super init]) {
		elementsToFields = [[NSDictionary alloc] initWithObjectsAndKeys:
							[NSNumber numberWithInt:Title],		@"title",
							[NSNumber numberWithInt:URL],		@"link",
							[NSNumber numberWithInt:Body],		@"description",
							[NSNumber numberWithInt:Body],		@"content:encoded",
							[NSNumber numberWithInt:PubDate],	@"dc:date",
							nil];
	}
	
	return self;
}

- (void)dealloc {
	[elementsToFields release];
	[super dealloc];
}

/** Invoked when there's no currently active item. Respond YES to start one. */
- (BOOL)isItemStartElement:(NSString *)elementName 
			  namespaceURI:(NSString *)namespaceURI 
			 qualifiedName:(NSString *)qualifiedName 
				attributes:(NSDictionary *)attributeDict {
	return [@"item" caseInsensitiveCompare:elementName] == NSOrderedSame;
}

/** Invoked when an element inside an item is found. Process it if you need. */
- (void)handleItemElement:(NSString *)elementName 
			 namespaceURI:(NSString *)namespaceURI 
			qualifiedName:(NSString *)qualifiedName 
			   attributes:(NSDictionary *)attributeDict {
	NSNumber *field = [elementsToFields objectForKey:[qualifiedName lowercaseString]];
	if (field != nil) {
		if ([@"content:encoded" caseInsensitiveCompare:qualifiedName] == NSOrderedSame) currentItem.body = nil;
		if ([field intValue] != Body || currentItem.body == nil) {
			[self setCurrentField:[field intValue]];
		}
	}
}

/** Invoked when an element is closed when inside an item. */
- (BOOL)isItemEndElement:(NSString *)elementName
			namespaceURI:(NSString *)namespaceURI
		   qualifiedName:(NSString *)qName {
	return [@"item" caseInsensitiveCompare:elementName] == NSOrderedSame;
}

@end
