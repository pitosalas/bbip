//
//  OPMLParser.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OPMLGuide, OPMLFeed;

@interface OPMLParser : NSObject {
	NSMutableArray  *guides;
	OPMLGuide		*currentGuide;
}

/** Returns the list of OPMLGuide objects from URL. */
- (NSArray *)parseURL:(NSURL *)url;

/** Returns the list of OPMLGuide objects from OPML string. */
- (NSArray *)parseString:(NSString *)opml;

@end

@interface OPMLParser (private)

/** Returns the list of OPMLGuide objects from the configured parser. */
- (NSArray *)parse:(NSXMLParser *)parser;

/** Parses the guide. */
- (OPMLGuide *)parseGuide:(NSDictionary *)attributeDict;

/** Parses the feed. */
- (OPMLFeed *)parseFeed:(NSDictionary *)attributeDict;

/** Parses the list of read keys. */
- (NSArray *)parseReadKeys:(NSDictionary *)attributeDict;

@end
