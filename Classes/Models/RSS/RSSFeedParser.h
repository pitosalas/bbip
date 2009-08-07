//
//  RSSFeedParser.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RSSFeedParser : NSObject {
}

/** Parses the feed from the given URL and returns the array of items. */
- (NSArray *)parseFeedFromURL:(NSURL *)url;

/** Parses the feed from the given data and returns the array of items. */
- (NSArray *)parseFeedFromData:(NSData *)data;

@end

#pragma mark -
#pragma mark Private

@interface RSSFeedParser (private)

/** Parses the feed from a pre-initialized parser and returns the array of items. */
- (NSArray *)parseFeedWithParser:(NSXMLParser *)parser;

@end
