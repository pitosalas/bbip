//
//  AbstractParserTests.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AbstractParserTests.h"
#import "AbstractParser.h"
#import "RSSItem.h";

#pragma mark TestParser

@interface TestParser : AbstractParser {
	BOOL itemStartCallbackReply;
	BOOL itemEndCallbackReply;
	
	int itemStartCalled;
	int itemEndCalled;
	int handleItemElementCalled;
}

@property (nonatomic, readonly) int itemStartCalled;
@property (nonatomic, readonly) int itemEndCalled;
@property (nonatomic, readonly) int handleItemElementCalled;

- (id)initWithItemStartCallbackReply:(BOOL)itemStartCallbackReply itemEndCallbackReply:(BOOL)itemEndCallbackReply;

@end

@implementation TestParser

@synthesize itemStartCalled, itemEndCalled, handleItemElementCalled;

- (id)initWithItemStartCallbackReply:(BOOL)anItemStartCallbackReply itemEndCallbackReply:(BOOL)anItemEndCallbackReply {
	if (self = [super init]) {
		itemStartCallbackReply	= anItemStartCallbackReply;
		itemEndCallbackReply	= anItemEndCallbackReply;
		
		itemStartCalled			= 0;
		itemEndCalled			= 0;
		handleItemElementCalled	= 0;
	}
	return self;
}

/** Invoked when there's no currently active item. Respond YES to start one. */
- (BOOL)isItemStartElement:(NSString *)elementName 
			  namespaceURI:(NSString *)namespaceURI 
			 qualifiedName:(NSString *)qualifiedName 
				attributes:(NSDictionary *)attributeDict {
	itemStartCalled++;
	return itemStartCallbackReply;
}

/** Invoked when an element inside an item is found. Process it if you need. */
- (void)handleItemElement:(NSString *)elementName 
			 namespaceURI:(NSString *)namespaceURI 
			qualifiedName:(NSString *)qualifiedName 
			   attributes:(NSDictionary *)attributeDict {
	handleItemElementCalled++;
}

/** Invoked when an element is closed when inside an item. */
- (BOOL)isItemEndElement:(NSString *)elementName
			namespaceURI:(NSString *)namespaceURI
		   qualifiedName:(NSString *)qName {
	itemEndCalled++;
	return itemEndCallbackReply;
}

@end

#pragma mark -

@implementation AbstractParserTests

- (void)setUp {
	parser = [AbstractParser new];
}

- (void)tearDown {
	[parser release];
}

#pragma mark Basic tests

- (void)testStartingNewItems {
	STAssertEquals((int)[parser.items count], 0, @"Should be empty initially");
	
	RSSItem *item = [parser startNewItem];
	STAssertEquals((int)[parser.items count], 0, @"Should not add anything as nothing was started yet");
	STAssertNotNil(item, @"Should return new item");
}

- (void)testSavingItems {
	[parser saveCurrentItem];
	STAssertEquals((int)[parser.items count], 0, @"Should not add anything as nothing was started yet");

	RSSItem *item = [parser startNewItem];
	[parser saveCurrentItem];
	STAssertEquals((int)[parser.items count], 1, @"Should add one item");
	STAssertEqualObjects([parser.items objectAtIndex:0], item, @"Wrong object saved");
}

- (void)testSetCurrentFieldAndInitialize {
	RSSItem *item = [parser startNewItem];
	[parser setCurrentField:Title];
	[parser appendContentToField:@"test"];
	STAssertEqualObjects(item.title, @"test", @"Title was selected as the target");
}

- (void)testSetCurrentFieldAndAppend {
	RSSItem *item = [parser startNewItem];
	[parser setCurrentField:Title];
	[parser appendContentToField:@"te"];
	[parser appendContentToField:@"st"];
	STAssertEqualObjects(item.title, @"test", @"Title was selected as the target");
}

- (void)testAppendingToNoneField {
	RSSItem *item = [parser startNewItem];
	[parser appendContentToField:@"test"];
	STAssertNil(item.pubDate, @"Should not change");
	STAssertNil(item.title, @"Should not change");
	STAssertNil(item.body, @"Should not change");
	STAssertNil(item.url, @"Should not change");
}

#pragma mark -
#pragma mark Parsing scenarios

- (void)testItemStart {
	[self initTestParserWithStartReply:YES endReply:NO];
	[parser parser:nil didStartElement:@"start" namespaceURI:nil qualifiedName:@"start" attributes:nil];
	STAssertEquals(((TestParser *)parser).itemStartCalled, 1, @"Wrong number of calls");
	STAssertNotNil(parser.currentItem, @"New item should start");
}

- (void)testItemStartWrongElement {
	[self initTestParserWithStartReply:NO endReply:NO];
	[parser parser:nil didStartElement:@"no-start" namespaceURI:nil qualifiedName:@"no-start" attributes:nil];
	STAssertEquals(((TestParser *)parser).itemStartCalled, 1, @"Wrong number of calls");
	STAssertNil(parser.currentItem, @"New item should not start");
}

- (void)testItemEnd {
	[self initTestParserWithStartReply:NO endReply:YES];
	[parser startNewItem];
	[parser parser:nil didEndElement:@"end" namespaceURI:nil qualifiedName:@"end"];
	STAssertEquals(((TestParser *)parser).itemEndCalled, 1, @"Wrong number of calls");
	STAssertNil(parser.currentItem, @"New item should end");
}

- (void)testItemEndWrongElement {
	[self initTestParserWithStartReply:NO endReply:NO];
	[parser startNewItem];
	[parser parser:nil didEndElement:@"no-end" namespaceURI:nil qualifiedName:@"no-end"];
	STAssertEquals(((TestParser *)parser).itemEndCalled, 1, @"Wrong number of calls");
	STAssertNotNil(parser.currentItem, @"New item should not end");
}

- (void)testHandlingItemElement {
	[self initTestParserWithStartReply:NO endReply:NO];
	[parser startNewItem];
	[parser parser:nil didStartElement:@"title" namespaceURI:nil qualifiedName:@"title" attributes:nil];
	STAssertEquals(((TestParser *)parser).handleItemElementCalled, 1, @"Wrong number of calls");
}

#pragma mark -
#pragma mark Helpers

- (void)initTestParserWithStartReply:(BOOL)startReply endReply:(BOOL)endReply {
	[parser release];
	parser = [[TestParser alloc] initWithItemStartCallbackReply:startReply itemEndCallbackReply:endReply];
}

@end
