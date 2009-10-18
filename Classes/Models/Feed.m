// 
//  Feed.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 10/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Feed.h"

#import "Guide.h"
#import "Article.h"

@implementation Feed 

@dynamic handlingType;
@dynamic url;
@dynamic latestArticleKey;
@dynamic name;
@dynamic incomingReadArticlesKeys;
@dynamic updatedOn;
@dynamic guides;
@dynamic articles;

/** Marks articles as read with incoming keys. */
- (void) markArticlesAsReadWithIncomingKeys {
	NSArray  *keys = [self getReadKeys];
	if (keys == nil) return;
	
	NSNumber *read = [NSNumber numberWithBool:TRUE];
	for (Article *article in self.articles) {
		if ([keys containsObject:article.matchKey]) article.read = read;
	}
	
	/* Reset the keys not to mark over and over. */
	self.incomingReadArticlesKeys = nil;
}

/** Returns true if the article match key is among the recorded read keys. */
- (BOOL) knowsArticleAsRead:(Article *)article {
	if (article == nil) return NO;
	NSArray *keys = [self getReadKeys];
	return keys != nil && [keys containsObject:article.matchKey];
}

/** Returns the array with article keys. */
- (NSArray *) getReadKeys {
	NSArray *keys = nil;
	
	if ((self.incomingReadArticlesKeys != nil) && ([self.incomingReadArticlesKeys length] > 0)) {
		keys = [self.incomingReadArticlesKeys componentsSeparatedByString:@","];
	}
		
	return keys;
}

@end
