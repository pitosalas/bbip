//
//  BlogBridgeAppDelegate.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/5/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

@class GuidesTabController, RSSUpdater;

@interface BlogBridgeAppDelegate : NSObject <UIApplicationDelegate> {
    
    NSManagedObjectModel			*managedObjectModel;
    NSManagedObjectContext			*managedObjectContext;	    
    NSPersistentStoreCoordinator	*persistentStoreCoordinator;

    UIWindow						*window;
	GuidesTabController				*tabBarController;
	RSSUpdater						*updater;
}

- (IBAction)saveAction:sender;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

/** Private methods */
@interface BlogBridgeAppDelegate (private)

/** Makes sure the database file is there and loaded with defaults. */
- (void)initDefaultDatabaseIfNeeded;

/** Takes OPML from the server if possible and updates the list of guides. */
- (void)updateOPML;

/** Returns current OPML URL. */
- (NSString *)opmlURL;

/** Returns YES if connected. */
- (BOOL)isConnected;

/** Initializes the default preferences. */
- (void)initDefaultUserPreferences;

@end
