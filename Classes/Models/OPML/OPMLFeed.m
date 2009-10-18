//
//  OPMLFeed.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OPMLFeed.h"


@implementation OPMLFeed

@synthesize title, xmlURL, htmlURL, readArticleKeys, handlingType;

- (id)initWithTitle:(NSString *)aTitle xmlURL:(NSString *)anXmlURL htmlURL:(NSString *)anHtmlURL readArticleKeys:(NSString *)aReadArticleKeys handlingType:(NSNumber *)aHandlingType {
	if (self = [super init]) {
		title			= [aTitle copy];
		xmlURL			= [anXmlURL copy];
		htmlURL			= [anHtmlURL copy];
		readArticleKeys	= [aReadArticleKeys copy];
		handlingType	= [aHandlingType copy];
	}
	
	return self;
}

- (void)dealloc {
	[title release];
	[xmlURL release];
	[htmlURL release];
	[readArticleKeys release];
	[handlingType release];
	[super dealloc];
}

@end
