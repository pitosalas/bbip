//
//  GuideViewController.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/5/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

@class Guide, CellsOwner;

@interface GuideViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController	*fetchedResultsController;
	NSManagedObjectContext		*managedObjectContext;
	
	Guide						*guide;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (id)initWithGuide:(Guide *)aGuide;

#pragma mark -
#pragma mark Notifications

/** Invoked when new articles are added to a feed. */
- (void)onArticlesAdded:(NSNotification *)notification;

@end
