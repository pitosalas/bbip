//
//  RSSFeedParserTests.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <Foundation/Foundation.h>

@class RSSFeedParser;

@interface RSSFeedParserTests : SenTestCase {
	RSSFeedParser *parser;
}

/** Returns the data object filled with the context of the fixture. */
- (NSData *)fixtureData:(NSString *)name;

@end
