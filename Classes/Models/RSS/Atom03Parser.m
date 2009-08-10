//
//  Atom03Parser.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Atom03Parser.h"
#import "RSSItem.h"

@implementation Atom03Parser

- (id)init {
	if (self = [super init]) {
		elementsToFields = [[NSDictionary alloc] initWithObjectsAndKeys:
							[NSNumber numberWithInt:Title],		@"title",
							[NSNumber numberWithInt:Body],		@"summary",
							[NSNumber numberWithInt:PubDate],	@"modified",
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
	return [@"entry" caseInsensitiveCompare:elementName] == NSOrderedSame;
}

/** Invoked when an element inside an item is found. Process it if you need. */
- (void)handleItemElement:(NSString *)elementName 
			 namespaceURI:(NSString *)namespaceURI 
			qualifiedName:(NSString *)qualifiedName 
			   attributes:(NSDictionary *)attributeDict {
	NSNumber *field = [elementsToFields objectForKey:[qualifiedName lowercaseString]];
	if (field != nil) {
		int ifield = [field intValue];
		[self setCurrentField:ifield];
	} else if ([@"link" caseInsensitiveCompare:qualifiedName] == NSOrderedSame) {
		// Link
		NSString *rel = [attributeDict valueForKey:@"rel"];
		if (rel == nil || [@"alternate" caseInsensitiveCompare:rel] == NSOrderedSame) {
			currentItem.url = [attributeDict valueForKey:@"href"];
			currentField = None;
		}
	}
}

/** Invoked when an element is closed when inside an item. */
- (BOOL)isItemEndElement:(NSString *)elementName
			namespaceURI:(NSString *)namespaceURI
		   qualifiedName:(NSString *)qName {
	return [@"entry" caseInsensitiveCompare:elementName] == NSOrderedSame;
}

@end
