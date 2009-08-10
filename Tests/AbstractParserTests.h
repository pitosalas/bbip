//
//  AbstractParserTests.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <Foundation/Foundation.h>

@class AbstractParser;

@interface AbstractParserTests : SenTestCase {
	AbstractParser *parser;
}

- (void)initTestParserWithStartReply:(BOOL)startReply endReply:(BOOL)endReply;

@end
