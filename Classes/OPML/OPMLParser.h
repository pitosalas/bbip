//
//  OPMLParser.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OPMLGuide;

@interface OPMLParser : NSObject {
	NSMutableArray  *guides;
	OPMLGuide		*currentGuide;
}

/**
 * Returns the list of OPMLGuide objects.
 */
- (NSArray *)parseURL:(NSURL *)url;

- (void)parseGuide:(NSDictionary *)attributeDict;
- (void)parseFeed:(NSDictionary *)attributeDict;
- (NSArray *)parseReadKeys:(NSDictionary *)attributeDict;

@end
