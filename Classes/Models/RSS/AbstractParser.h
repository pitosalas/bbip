//
//  AbstractParser.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSSItem;

typedef enum ItemFieldType {
	None	= 0,
	Title	= 1,
	Body	= 2,
	URL		= 3,
	PubDate	= 4
} ItemField;

@interface AbstractParser : NSObject {
	NSMutableArray	*items;
	
	RSSItem			*currentItem;
	ItemField		currentField;
}

@property (nonatomic, readonly) NSMutableArray	*items;
@property (nonatomic, readonly) RSSItem			*currentItem;

/** Saves current item. */
- (void)saveCurrentItem;

/** Saves current item and starts a new one. */
- (RSSItem *)startNewItem;

/** Sets the field to send new content over to. */
- (void)setCurrentField:(ItemField)field;

/** Appends content to the currently selected item field. */
- (void)appendContentToField:(NSString *)content;

#pragma mark -
#pragma mark Delegation

/** Invoked by the parser when the opening element is found. */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName 
	attributes:(NSDictionary *)attributeDict;

/** Invoked by the parser when the closing element is found. */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName;

/** Invoked when characters found inside the current element. Can be invoked multiple times. */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;

/** Invoked when CDATA block is found. */
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock;

#pragma mark -
#pragma mark Callbacks

/** Invoked when there's no currently active item. Respond YES to start one. */
- (BOOL)isItemStartElement:(NSString *)elementName 
			  namespaceURI:(NSString *)namespaceURI 
			 qualifiedName:(NSString *)qualifiedName 
				attributes:(NSDictionary *)attributeDict;

/** Invoked when an element inside an item is found. Process it if you need. */
- (void)handleItemElement:(NSString *)elementName 
			 namespaceURI:(NSString *)namespaceURI 
			qualifiedName:(NSString *)qualifiedName 
			   attributes:(NSDictionary *)attributeDict;

/** Invoked when an element is closed when inside an item. */
- (BOOL)isItemEndElement:(NSString *)elementName
			namespaceURI:(NSString *)namespaceURI
		   qualifiedName:(NSString *)qName;

@end
