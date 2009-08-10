//
//  OPMLUpdater.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

@interface OPMLUpdater : NSObject {
}

/** Updates the model from the OPML url. */
- (void)updateFromOPMLURL:(NSURL *)url managedObjectContext:(NSManagedObjectContext *)context;

@end

@interface OPMLUpdater (private)

/** Returns the set of all feeds mentioned in all guides. */
- (NSSet *)collectFeedsFromGuides:(NSArray *)guides;

/** Adds new feeds and removes those no longer on the list. */
- (void)syncFeeds:(NSSet *)feeds inManagedObjectContext:(NSManagedObjectContext *)context;

/** Adds new guides, removes deleted and re-links feeds. */
- (void)syncGuides:(NSArray *)guides inManagedObjectContext:(NSManagedObjectContext *)context;

/** Returns all entities of a given kind. */
- (NSArray *)requestAll:(NSString *)entityName inManagedObjectContext:(NSManagedObjectContext *)context;

/** Removes unlinked feeds with their articles. */
- (void)removeUnlinkedFeedsInManagedObjectContext:(NSManagedObjectContext *)context;

@end
