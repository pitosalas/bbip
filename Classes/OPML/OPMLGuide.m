//
//  OPMLGuide.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OPMLGuide.h"


@implementation OPMLGuide

@synthesize name, iconName, feeds;

/**
 * Initializes the guide with name and icon name.
 */
- (id)initWithName:(NSString *)aName iconName:(NSString *)anIconName {
	if (self = [super init]) {
		name		= [aName copy];
		iconName	= [anIconName copy];
		feeds		= [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {
	[name release];
	[iconName release];
	[feeds release];
	[super dealloc];
}

/**
 * Adds a single feed to the list.
 */
- (void)addFeed:(OPMLFeed *)feed {
	[feeds addObject:feed];
}

@end
