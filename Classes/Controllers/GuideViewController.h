//
//  GuideViewController.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/5/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

@class Guide, Article, CellsOwner, ArticleViewController;

@interface GuideViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController	*fetchedResultsController;
	NSManagedObjectContext		*managedObjectContext;
	
	Guide						*guide;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (id)initWithGuide:(Guide *)aGuide;

/** Updates the badge. */
- (void)updateBadge;

#pragma mark -
#pragma mark Notifications

/** Invoked when new articles are added to a feed. */
- (void)onArticlesAdded:(NSNotification *)notification;

/** Invoked when an article is read. */
- (void)onArticleRead:(NSNotification *)notification;

/** Marks an article as read and notifies everyone. */
- (void)markArticleAsReadAndNotify:(Article *)article;

/** Moves to the next article with the delta. */
- (void)onNextArticle:(ArticleViewController *)articleViewController withDelta:(int)delta;

@end
