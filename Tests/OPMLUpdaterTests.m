//
//  OPMLUpdaterTests.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OPMLUpdaterTests.h"
#import "OPMLUpdater.h"
#import "OPMLGuide.h"
#import "OPMLFeed.h"

@implementation OPMLUpdaterTests

- (void)setUp {
	updater = [OPMLUpdater new];
}

- (void)tearDown {
	[updater release];
	/*
	[managedObjectContext release];
	[managedObjectModel release];
	[persistentStoreCoordinator release];
	*/
}

- (void)testCollectFeedsFromGuides {
	// Create 4 feeds with one duplicate (feed22)
	OPMLFeed *feed11  = [[OPMLFeed alloc] initWithTitle:@"t11" xmlURL:@"1" htmlURL:@"" readArticleKeys:nil];
	OPMLFeed *feed12  = [[OPMLFeed alloc] initWithTitle:@"t12" xmlURL:@"2" htmlURL:@"" readArticleKeys:nil];
	OPMLFeed *feed21  = [[OPMLFeed alloc] initWithTitle:@"t21" xmlURL:@"3" htmlURL:@"" readArticleKeys:nil];
	OPMLFeed *feed22  = [[OPMLFeed alloc] initWithTitle:@"t11" xmlURL:@"1" htmlURL:@"" readArticleKeys:nil];

	// Create two guides with feeds in them
	OPMLGuide *guide1 = [[OPMLGuide alloc] initWithName:@"g1" iconName:@"i1"];
	[guide1 addFeed:feed11];
	[guide1 addFeed:feed12];
	OPMLGuide *guide2 = [[OPMLGuide alloc] initWithName:@"g2" iconName:@"i2"];
	[guide2 addFeed:feed21];
	[guide2 addFeed:feed22];

	// Check the results
	NSSet *feeds = [updater collectFeedsFromGuides:[NSArray arrayWithObjects:guide1, guide2, nil]];
	STAssertEquals((int)[feeds count], 3, @"One duplicate feed shouldn't be mentioned");
	STAssertTrue([feeds containsObject:feed11], @"No feed");
	STAssertTrue([feeds containsObject:feed12], @"No feed");
	STAssertTrue([feeds containsObject:feed21], @"No feed");
	
	[guide1 release];
	[guide2 release];
	[feed11 release];
	[feed12 release];
	[feed21 release];
	[feed22 release];
}

/*
- (void)testSyncFeeds {
	NSError *error;

	// Create feeds and give them to syncFeeds
	NSManagedObjectContext *context = [self managedObjectContext];
	OPMLFeed *feed11  = [[OPMLFeed alloc] initWithTitle:@"t11" xmlURL:@"1" htmlURL:@"" readArticleKeys:nil];
	OPMLFeed *feed12  = [[OPMLFeed alloc] initWithTitle:@"t12" xmlURL:@"2" htmlURL:@"" readArticleKeys:nil];
	OPMLFeed *feed21  = [[OPMLFeed alloc] initWithTitle:@"t21" xmlURL:@"3" htmlURL:@"" readArticleKeys:nil];
	[updater syncFeeds:[NSSet setWithObjects:feed11, feed12, feed21, nil] managedObjectContext:context];
	[context save:&error];
	
	// Fetch all feeds from the context
	NSFetchRequest *req = [[NSFetchRequest alloc] init];
	[req setEntity:[NSEntityDescription entityForName:@"Feed" inManagedObjectContext:context]];
	NSArray *feeds = [context executeFetchRequest:req error:&error];
	
	STAssertEquals((int)[feeds count], 3, @"Feeds must be added");
}
*/

/*
#pragma mark -
#pragma mark Core Data stack

- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) return managedObjectContext;
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
	
	return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) return managedObjectModel;
	managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) return persistentStoreCoordinator;
	
	NSError *error;

	NSString *path  = [@"/tmp" stringByAppendingPathComponent: @"BlogBridge.sqlite"];
    NSURL *storeUrl = [NSURL fileURLWithPath:path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:path error:&error];
	
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error];
	
    return persistentStoreCoordinator;
}
*/
@end
