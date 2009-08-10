//
//  RSSUpdater.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface RSSUpdater : NSObject {
	NSManagedObjectContext *context;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context;

/** Updates all feeds that are ready to be updated. */
- (void)update;

@end


@interface RSSUpdater (private)

/** Returns the list of feeds that are ready for update now. */
- (NSArray *)findFeedsToUpdate;

/** Creates a dictionary of ObjectID's -> feed.url. */
- (NSDictionary *)mapFeedIDsToURLs:(NSArray *)feeds;

/** Updates a feed. */
- (void)updateFeed:(NSManagedObject *)feed;

@end
