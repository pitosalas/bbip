//
//  OPMLFeed.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OPMLFeed.h"


@implementation OPMLFeed

@synthesize title, xmlURL, htmlURL, readArticleKeys;

- (id)initWithTitle:(NSString *)aTitle xmlURL:(NSString *)anXmlURL htmlURL:(NSString *)anHtmlURL readArticleKeys:(NSArray *)aReadArticleKeys {
	if (self = [super init]) {
		title			= [aTitle copy];
		xmlURL			= [anXmlURL copy];
		htmlURL			= [anHtmlURL copy];
		readArticleKeys	= [aReadArticleKeys copy];
	}
	
	return self;
}

- (void)dealloc {
	[title release];
	[xmlURL release];
	[htmlURL release];
	[readArticleKeys release];
	[super dealloc];
}

@end
