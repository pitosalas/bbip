//
//  AbstractParser.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AbstractParser.h"
#import "RSSItem.h"


@implementation AbstractParser

@synthesize items, currentItem;

- (id)init {
	if (self = [super init]) {
		items = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc {
	[currentItem release];
	[items release];
	[super dealloc];
}

/** Saves current item. */
- (void)saveCurrentItem {
	if (currentItem != nil) {
		[self.items addObject:currentItem];
		[currentItem release];

		currentItem  = nil;
		currentField = None;
	}
}

/** Saves current item and starts a new one. */
- (RSSItem *)startNewItem {
	currentItem  = [RSSItem new];
	currentField = None;
	return currentItem;
}

/** Sets the field to send new content over to. */
- (void)setCurrentField:(ItemField)field {
	currentField = field;
}

/** Appends content to the currently selected item field. */
- (void)appendContentToField:(NSString *)content {
	if (currentItem == nil) return;
	
	switch (currentField) {
		case Title:
			currentItem.title = currentItem.title ? [currentItem.title stringByAppendingString:content] : [content copy];
			break;
		case Body:
			currentItem.body = currentItem.body ? [currentItem.body stringByAppendingString:content] : [content copy];
			break;
		case URL:
			currentItem.url = currentItem.url ? [currentItem.url stringByAppendingString:content] : [content copy];
			break;
		case PubDate:
			currentItem.pubDate = currentItem.pubDate ? [currentItem.pubDate stringByAppendingString:content] : [content copy];
			break;
		default:
			break;
	}
}

#pragma mark -
#pragma mark Delegation

/** Invoked by the parser when the opening element is found. */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName 
	attributes:(NSDictionary *)attributeDict {
	
	if (currentItem == nil) {
		if ([self isItemStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict]) {
			[self startNewItem];
		}
	} else {
		[self handleItemElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];
	}
}

/** Invoked by the parser when the closing element is found. */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName {
	
	if (currentItem != nil) {
		currentField = None;
		
		if ([self isItemEndElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName]) {
			[self saveCurrentItem];
		}
	}
}

/** Invoked when characters found inside the current element. Can be invoked multiple times. */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[self appendContentToField:string];
}

/** Invoked when CDATA block is found. */
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
	NSString *string = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
	[self parser:parser foundCharacters:string];
	[string release];
}

#pragma mark -
#pragma mark Callbacks

/** Invoked when there's no currently active item. Respond YES to start one. */
- (BOOL)isItemStartElement:(NSString *)elementName 
			  namespaceURI:(NSString *)namespaceURI 
			 qualifiedName:(NSString *)qualifiedName 
				attributes:(NSDictionary *)attributeDict {
	return NO;
}

/** Invoked when an element inside an item is found. Process it if you need. */
- (void)handleItemElement:(NSString *)elementName 
			 namespaceURI:(NSString *)namespaceURI 
			qualifiedName:(NSString *)qualifiedName 
			   attributes:(NSDictionary *)attributeDict {
}

/** Invoked when an element is closed when inside an item. */
- (BOOL)isItemEndElement:(NSString *)elementName
			namespaceURI:(NSString *)namespaceURI
		   qualifiedName:(NSString *)qName {
	return NO;
}

@end
