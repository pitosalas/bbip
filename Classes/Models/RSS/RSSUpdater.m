//
//  RSSUpdater.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RSSUpdater.h"
#import "Constants.h"
#import "RSSFeedParser.h"
#import "RSSItem.h"
#import "Article.h"
#import "Guide.h"

@implementation RSSUpdater

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)aContext {
	if (self = [super init]) {
		context = [aContext retain];
		lock = [NSLock new];
	}
	return self;
}

- (void)dealloc {
	[lock release];
	[context release];
	[super dealloc];
}

/** Updates all feeds that are ready to be updated. */
- (void)update {
	if ([lock tryLock]) {
		NSArray *feedsToUpdate = [self findFeedsToUpdate];
		NSLog(@"Updater: Feeds to update %d", [feedsToUpdate count]);

		if ([feedsToUpdate count] > 0) {
			NSDictionary *feedIDToURL = [self mapFeedIDsToURLs:feedsToUpdate];
			[self performSelectorInBackground:@selector(updateFeeds:) withObject:feedIDToURL];
		}
	}
}

#pragma mark -
#pragma mark Private

/** Returns the list of feeds that are ready for update now. */
- (NSArray *)findFeedsToUpdate {
	NSFetchRequest *req = [NSFetchRequest new];

	// Set entity
	NSEntityDescription *feedEntity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:context];
	[req setEntity:feedEntity];
	
	// Select only feeds that are older than some given value
	int updatePeriod = [[NSUserDefaults standardUserDefaults] integerForKey:BBSettingUpdatePeriod];
	NSDate *borderDate = [NSDate dateWithTimeIntervalSinceNow:-updatePeriod];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(updatedOn = $DATE) OR (updatedOn < %@)", borderDate];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:[NSNull null] forKey:@"DATE"]];
	[req setPredicate:predicate];
	
	// Fetch feeds
	NSError *error;
	NSArray *feeds = [context executeFetchRequest:req error:&error];
	
	[req release];
	
	return feeds;
}

/** Creates a dictionary of ObjectID's -> feed.url. */
- (NSDictionary *)mapFeedIDsToURLs:(NSArray *)feeds {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	for (NSManagedObject *feed in feeds) {
		[dict setObject:[feed valueForKey:@"url"] forKey:[feed objectID]];
	}
	
	return dict;
}

/** Updates feeds. */
- (void)updateFeeds:(NSDictionary *)feedIDsToURLs {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	RSSFeedParser *parser = [RSSFeedParser new];
	
	for (NSManagedObjectID *feedID in feedIDsToURLs) {
		NSString *url  = [feedIDsToURLs objectForKey:feedID];
		NSLog(@"Updating %@", url);
		NSArray *items = [[parser parseFeedFromURL:[NSURL URLWithString:url]] retain];
		NSLog(@"Fetched %d articles", [items count]);
		
		// Send updates
		NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:feedID, @"feedID", items, @"items", nil];
		[self performSelectorOnMainThread:@selector(fetchedUpdatesForFeed:) withObject:args waitUntilDone:NO];
	}
	
	[parser release];
	[pool release];
}

/** Invoked in the main thread context when the feed is updated. */
- (void)fetchedUpdatesForFeed:(NSDictionary *)args {
	NSManagedObjectID *feedID	= [args objectForKey:@"feedID"];
	NSArray *items				= [args objectForKey:@"items"];
	
	NSManagedObject *feed = [context objectWithID:feedID];

	// See if there are any updates
	NSMutableArray *addedArticles		= [NSMutableArray array];
	NSString *latestSeenArticleKey		= [feed valueForKey:@"latestArticleKey"];
	NSEntityDescription *articleEntity	= [NSEntityDescription entityForName:@"Article" inManagedObjectContext:context];
	int timeOffset						= 0;
	BOOL addedNewArticles				= NO;
	
	for (RSSItem *item in items) {
		if ([item.key caseInsensitiveCompare:latestSeenArticleKey]) {
			addedNewArticles = YES;
			
			// Item is new
			Article *article = [[NSManagedObject alloc] initWithEntity:articleEntity insertIntoManagedObjectContext:context];
			article.title   = [item.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			article.body	= item.body;
			article.url		= item.url;
			article.pubDate	= item.pubDateObject ? item.pubDateObject : [NSDate dateWithTimeIntervalSinceNow:-(timeOffset++)];
			article.read	= NO;
			article.feed    = feed;
			
			[addedArticles addObject:article];
			
			[article release];
		} else break;
	}

	// Set last update date, last seen article key and save changes
	NSError *error;
	[feed setValue:[NSDate date] forKey:@"updatedOn"];
	if (addedNewArticles) {
		[feed setValue:((RSSItem *)[items objectAtIndex:0]).key forKey:@"latestArticleKey"];
		
		// Update guides' unread counters
		NSSet *guides = [feed valueForKeyPath:@"guides"];
		for (Guide *guide in guides) {
			guide.unreadCount = [NSNumber numberWithInt:([guide.unreadCount intValue] + [addedArticles count])];
		}
	}

	if (![context save:&error]) {
		NSLog(@"Failed to update: %@", error);
	}

	// Send notifications if any articles were added
	if (addedNewArticles) {
		NSLog(@"Added: %d articles, lastSeen: %@", [addedArticles count], ((RSSItem *)[items objectAtIndex:0]).key);
		
		// List a feed and all added articles
		NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
							  feed,				@"feed",
							  addedArticles,	@"addedArticles",
							  nil];
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc postNotificationName:BBNotificationArticlesAdded object:self userInfo:info];
	}
}

@end
