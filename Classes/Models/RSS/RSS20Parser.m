//
//  RSS20Parser.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RSS20Parser.h"
#import "RSSItem.h"

@implementation RSS20Parser

- (id)init {
	if (self = [super init]) {
		elementsToFields = [[NSDictionary alloc] initWithObjectsAndKeys:
							[NSNumber numberWithInt:Title],		@"title",
							[NSNumber numberWithInt:URL],		@"link",
							[NSNumber numberWithInt:URL],		@"guid",
							[NSNumber numberWithInt:Body],		@"description",
							[NSNumber numberWithInt:Body],		@"content:encoded",
							[NSNumber numberWithInt:PubDate],	@"pubdate",
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
		int ifield = [field intValue];
		
		// Give priority to <content:encoded> over <description> and <guid isPermalink='true'> over <link>
		if ([@"content:encoded" caseInsensitiveCompare:qualifiedName] == NSOrderedSame) currentItem.body = nil;
		if ([@"guid" caseInsensitiveCompare:qualifiedName] == NSOrderedSame) {
			if ([@"true" caseInsensitiveCompare:[attributeDict valueForKey:@"isPermaLink"]] == NSOrderedSame) {
				currentItem.url = nil;
			} else {
				ifield = -1;
			}
		}
		
		if ((ifield != Body || currentItem.body == nil) && (ifield != URL || currentItem.url == nil)) {
			if (ifield != -1) [self setCurrentField:ifield];
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
