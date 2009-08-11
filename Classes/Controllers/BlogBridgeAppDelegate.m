//
//  BlogBridgeAppDelegate.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/5/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "BlogBridgeAppDelegate.h"
#import "GuideViewController.h"
#import "GuidesTabController.h"
#import "Guide.h"
#import "OPMLUpdater.h"
#import "Cleaner.h"
#import "Constants.h"
#import "RSSUpdater.h"

/** Simple MD5 key creation. */
NSString* md5(NSString *str) {
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5(cStr, strlen(cStr), result);
	
	return [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2],  result[3],  result[4],  result[5],  result[6],  result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}



@implementation BlogBridgeAppDelegate

@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	NSDate *hideSplashScreenAfter = [NSDate dateWithTimeIntervalSinceNow:2];
	
	[self initDefaultUserPreferences];
//	[self initDefaultDatabaseIfNeeded];
	[self updateOPML];
	
	// Clean articles
	Cleaner *cleaner = [[Cleaner alloc] initWithManagedObjectContext:self.managedObjectContext];
	[cleaner performCleanup];
	[cleaner release];

	// Create the updater
	updater = [[RSSUpdater alloc] initWithManagedObjectContext:self.managedObjectContext];
	
	// Create tab bar controller
	tabBarController = [[GuidesTabController alloc] initWithManagedObjectContext:self.managedObjectContext];

	[window addSubview:tabBarController.view];

	// Wait a couple of seconds for the splash screen
	[NSThread sleepUntilDate:hideSplashScreenAfter];
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES]; 
	[window makeKeyAndVisible];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[updater update];
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
        } 
    }
}


#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender {
	
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) return managedObjectContext;
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
 
	return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) return managedObjectModel;

	managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    

    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) return persistentStoreCoordinator;
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"BlogBridge.sqlite"]];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
	
	//NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Handle error
		NSLog(@"%@", error);
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
	[updater release];
    
	[tabBarController release];
	[window release];
	[super dealloc];
}

/** Makes sure the database file is there and loaded with defaults. */
- (void)initDefaultDatabaseIfNeeded {
    // Check if the database exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"BlogBridge.sqlite"];

    if (![fileManager fileExistsAtPath:writableDBPath]) {
		// The writable database does not exist, so copy the default to the appropriate location.
		NSError *error;
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"BlogBridge.sqlite"];
		if (![fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error]) {
			NSLog(@"Failed to install default DB: %@", error);
		};
	}
}

/** Takes OPML from the server if possible and updates the list of guides. */
- (void)updateOPML {
	if ([self isConnected]) {
		NSString *opmlURL;
		
		// Take default for now
		opmlURL = [self opmlURL];
		
		OPMLUpdater *opmlUpdater = [[OPMLUpdater alloc] init];
		NSURL *url = [NSURL URLWithString:opmlURL];
		[opmlUpdater updateFromOPMLURL:url managedObjectContext:[self managedObjectContext]];
		[opmlUpdater release];
	}
}

/** Returns the OPML URL to take data from. */
- (NSString *)opmlURL {
	NSUserDefaults *prefs	= [NSUserDefaults standardUserDefaults];
	NSString *url			= [prefs stringForKey:BBSettingDefaultOpmlUrl];

	// User email and password
	NSString *email			= [prefs stringForKey:BBSettingAccountEmail];
	NSString *password		= [prefs stringForKey:BBSettingAccountPassword];
	if (email != nil) {
		email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		if ([email length] > 0) {
			NSString *key = password ? md5(password) : @"";
			url = [NSString stringWithFormat:@"http://blogbridge.com/mobile.opml?key=%@&email=%@", key, [email stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		}
	}
	
	return url;
}

/** Returns YES if connected. */
- (BOOL)isConnected {
	return YES;
}

- (void)initDefaultUserPreferences {
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	
	NSDictionary *userDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								  @"http://blogbridge.com/points/bbip.opml",	BBSettingDefaultOpmlUrl,
								  [NSNumber numberWithInt:100],					BBSettingCurrentFontBias,
								  [NSNumber numberWithInt:300],					BBSettingReadArticleAge,
								  [NSNumber numberWithInt:432000],				BBSettingUnreadArticleAge,
								  [NSNumber numberWithInt:1800],				BBSettingUpdatePeriod,
								  [NSNumber numberWithInt:0],					BBSettingSelectedGuide, nil];
	
	[ud registerDefaults:userDefaults];
}

@end

