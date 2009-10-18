//
//  OPMLUpdater.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "OPMLUpdater.h"
#import "OPMLParser.h"
#import "OPMLGuide.h"
#import "OPMLFeed.h"
#import "Guide.h"
#import "Feed.h"
#import "Article.h"

@implementation OPMLUpdater

/** Updates the model from the OPML url. */
- (void)updateFromOPMLURL:(NSURL *)url managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	NSArray *guides;
	
	// Parse guides
	OPMLParser *parser = [[OPMLParser alloc] init];
	guides = [parser parseURL:url];
	[guides retain];
	[parser release];
	
	if (guides != nil) {
		// Update feeds
		[self syncFeeds:[self collectFeedsFromGuides:guides] inManagedObjectContext:managedObjectContext];
		[self syncGuides:guides inManagedObjectContext:managedObjectContext];
		[self removeUnlinkedFeedsInManagedObjectContext:managedObjectContext];

		NSError *error;
		if (![managedObjectContext save:&error]) {
			NSLog(@"Failed to save OPML updates: %@", error);
		}
	}
}

#pragma mark -
#pragma mark Private

/** Returns the set of all feeds mentioned in all guides. */
- (NSSet *)collectFeedsFromGuides:(NSArray *)guides {
	NSMutableSet *feeds = [NSMutableSet set];
	NSMutableSet *urls  = [NSMutableSet set];
	
	for (OPMLGuide *guide in guides) {
		for (OPMLFeed *feed in guide.feeds) {
			if (![urls containsObject:feed.xmlURL]) {
				[feeds addObject:feed];
				[urls addObject:feed.xmlURL];
			}
		}
	}
	
	return feeds;
}

/** Adds new feeds and removes those no longer on the list. */
- (void)syncFeeds:(NSSet *)feeds inManagedObjectContext:(NSManagedObjectContext *)context {
	// Collect present URLs for matching
	NSDictionary *urlsToFeeds = [self getURLsToFeedsInContext:context];
	
	// See what feeds to add
	int added = 0;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:context];

	NSMutableSet *newURLs = [NSMutableSet new];
	for (OPMLFeed *opmlFeed in feeds) {
		NSString *xmlURL = [opmlFeed xmlURL];
		[newURLs addObject:xmlURL];
		
		Feed *presentFeed = [urlsToFeeds objectForKey:xmlURL];
		
		if (presentFeed == nil) {
			// New feed -- add
			Feed *feed = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
			feed.name			= opmlFeed.title;
			feed.url			= opmlFeed.xmlURL;
			feed.handlingType	= opmlFeed.handlingType;
			feed.incomingReadArticlesKeys = opmlFeed.readArticleKeys;

			[context insertObject:feed];
			[feed release];
			
			added++;
		} else {
			// Mark articles in this feed as read (those mentioned in the list of read keys)
			presentFeed.incomingReadArticlesKeys = opmlFeed.readArticleKeys;
			[presentFeed markArticlesAsReadWithIncomingKeys];
		}
	}
	
	NSLog(@"OPML Update: Added %d feed(s)", added);
	
	[newURLs release];
}

/** Adds new guides, removes deleted and re-links feeds. */
- (void)syncGuides:(NSArray *)guides inManagedObjectContext:(NSManagedObjectContext *)context {
	NSArray *presentGuides = [self requestAll:@"Guide" inManagedObjectContext:context];
	
	// Remove all present guides
	for (NSManagedObject *guide in presentGuides) {
		[context deleteObject:guide];
	}
	
	// Add all new guides back and link them to feeds
	NSDictionary *urlsToFeeds = [self getURLsToFeedsInContext:context];

	NSEntityDescription *guideEntity = [NSEntityDescription entityForName:@"Guide" inManagedObjectContext:context];
	for (OPMLGuide *opmlGuide in guides) {
		Guide *guide = [[NSManagedObject alloc] initWithEntity:guideEntity insertIntoManagedObjectContext:context];
		guide.name = opmlGuide.name;
		guide.iconName = opmlGuide.iconName;
		[context insertObject:guide];
		
		int unread = 0;
		
		for (OPMLFeed *opmlFeed in opmlGuide.feeds) {
			NSManagedObject *feed = [urlsToFeeds valueForKey:opmlFeed.xmlURL];
			if (feed != nil) {
				[guide addFeedsObject:feed];
				for (Article *article in [feed valueForKey:@"articles"]) {
					if (![article.read boolValue]) unread++;
				}
			}
		}
		
		// Set the number of unread articles in this guide
		guide.unreadCount = [NSNumber numberWithInt:unread];
		
		[guide release];
	}
}

/** Returns the dictionary of all URLs to Feeds. */
- (NSDictionary *) getURLsToFeedsInContext:(NSManagedObjectContext *)context {
	NSArray *presentFeeds = [self requestAll:@"Feed" inManagedObjectContext:context];
	NSMutableDictionary *urlsToFeeds = [NSMutableDictionary new];
	for (Feed *feed in presentFeeds) {
		[urlsToFeeds setObject:feed forKey:[feed valueForKey:@"url"]];
	}
	return [urlsToFeeds autorelease];
}

/** Removes unlinked feeds with their articles. */
- (void)removeUnlinkedFeedsInManagedObjectContext:(NSManagedObjectContext *)context {
	NSFetchRequest *req = [NSFetchRequest new];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:context];
	[req setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"guides.@count = 0"];
	[req setPredicate:predicate];
	
	NSError *error;
	NSArray *unlinkedFeeds = [context executeFetchRequest:req error:&error];
	
	for (NSManagedObject *feed in unlinkedFeeds) {
		[context deleteObject:feed];
	}

	NSLog(@"Removed %d unlinked feed(s)", [unlinkedFeeds count]);
	
	[req release];
}

/** Returns all entities of a given kind. */
- (NSArray *)requestAll:(NSString *)entityName inManagedObjectContext:(NSManagedObjectContext *)context {
	NSError *error;
	NSEntityDescription *entity;
	NSFetchRequest *req;

	entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
	req    = [NSFetchRequest new];
	[req setEntity:entity];
	NSArray *objects = [context executeFetchRequest:req error:&error];
	[req release];
	
	return objects;
}

@end
