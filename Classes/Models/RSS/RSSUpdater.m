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

@implementation RSSUpdater

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)aContext {
	if (self = [super init]) {
		context = [aContext retain];
	}
	return self;
}

- (void)dealloc {
	[context release];
	[super dealloc];
}

/** Updates all feeds that are ready to be updated. */
- (void)update {
	NSArray *feedsToUpdate = [self findFeedsToUpdate];

	if ([feedsToUpdate count] > 0) {
		NSDictionary *feedIDToURL = [self mapFeedIDsToURLs:feedsToUpdate];
		[self performSelectorInBackground:@selector(updateFeeds:) withObject:feedIDToURL];
	}
}

#pragma mark -
#pragma mark Private

/** Returns the list of feeds that are ready for update now. */
- (NSArray *)findFeedsToUpdate {
	NSFetchRequest *req = [NSFetchRequest new];

	// Set entity
	NSEntityDescription *feedEntity = [NSEntityDescription entityForName:@"feed" inManagedObjectContext:context];
	[req setEntity:feedEntity];
	
	// Select only feeds that are older than some given value
	int updatePeriod = [[NSUserDefaults standardUserDefaults] integerForKey:BBSettingUpdatePeriod];
	NSDate *borderDate = [NSDate dateWithTimeIntervalSinceNow:-updatePeriod];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"updatedAt IS NULL OR updatedAt < ?", borderDate];
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
		NSArray *items = [[parser parseFeedFromURL:[NSURL URLWithString:url]] retain];
		
		// Send updates
		NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:feedID, @"feedID", items, @"items", nil];
		[self performSelectorOnMainThread:@selector(fetchedUpdatesForFeed:) withObject:args waitUntilDone:NO];
	}
	
	[parser release];
	[pool release];
}

/** Updates a feed. */
- (void)updateFeedByObjectID:(NSManagedObjectID *)feedID url:(NSString *)url {
}

/** Invoked in the main thread context when the feed is updated. */
- (void)fetchedUpdatesForFeed:(NSDictionary *)args {
	NSManagedObjectID *feedID = [args objectForKey:@"feedID"];
	NSArray *items = [args objectForKey:@"items"];
}

@end
