//
//  GuideViewController.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/5/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "GuideViewController.h"
#import "Guide.h"
#import "Article.h"
#import "ArticleCell.h"
#import "ArticleViewController.h"
#import "Constants.h"

@implementation GuideViewController

@synthesize fetchedResultsController, managedObjectContext;

- (id)initWithGuide:(Guide *)aGuide {
	if (self = [super initWithStyle:UITableViewStylePlain]) {
		guide = [aGuide retain];

		self.title = guide.name;
		NSString *icon = [[guide.iconName componentsSeparatedByString:@"."] objectAtIndex:1];
		self.tabBarItem = [[[UITabBarItem alloc] 
							initWithTitle:guide.name 
							image:[UIImage imageNamed:[NSString stringWithFormat:@"images/%@.png", icon]] 
							tag:0] autorelease];
		[self updateBadge];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onArticlesAdded:) name:BBNotificationArticlesAdded object:nil]; 
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onArticleRead:) name:BBNotificationArticleRead object:nil]; 
	}
	
	return self;
}

- (void)dealloc {
	[guide release];
	[fetchedResultsController release];
	[managedObjectContext release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	NSError *error;
	[[self fetchedResultsController] performFetch:&error];
}

/** Updates the badge. */
- (void)updateBadge {
	int unread = [guide.unreadCount intValue];
	self.tabBarItem.badgeValue = unread > 0 ? [NSString stringWithFormat:@"%i", unread] : nil;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ArticleCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ArticleCell alloc] initWithIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	Article *article = (Article *)[fetchedResultsController objectAtIndexPath:indexPath];

	// Configure the cell
	cell.textLabel.text			= article.title;
	cell.detailTextLabel.text	= article.brief;
	
	cell.textLabel.textColor 	= [article.read boolValue] ? [UIColor colorWithRed:0.0f green:0.0f blue:0.5f alpha:0.5f] : [UIColor colorWithRed:0.0f green:0.0f blue:0.5f alpha:1.0f];
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	Article *article = (Article *)[fetchedResultsController objectAtIndexPath:indexPath];
	NSString *cellDetailText = article.brief;
	NSString *cellText = article.title;

	// The width subtracted from the tableView frame depends on:
	// 20.0 for detail accessory
	CGSize constraintSize = CGSizeMake(tableView.frame.size.width - 20.0, CGFLOAT_MAX);
	CGSize labelSize      = [cellText       sizeWithFont:[UIFont boldSystemFontOfSize:BBArticleCellTextFontSize] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	CGSize detailSize     = [cellDetailText sizeWithFont:[UIFont systemFontOfSize:BBArticleCellDetailFontSize] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	
	return labelSize.height + detailSize.height + 12;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Article *article = (Article *)[fetchedResultsController objectAtIndexPath:indexPath];
	
	// Show article panel
	ArticleViewController *articleViewController = [[ArticleViewController alloc] initWithArticle:article];
	articleViewController.navDelegate = self;
	[self.navigationController pushViewController:articleViewController animated:YES];
	[articleViewController release];

	// Mark article as read and update the row
	[self markArticleAsReadAndNotify:article];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController != nil) return fetchedResultsController;
    
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ANY feed.guides == %@", guide]];
	
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] 
															 initWithFetchRequest:fetchRequest 
															 managedObjectContext:managedObjectContext 
															 sectionNameKeyPath:nil 
															 cacheName:@"GuideArticles"];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    

/** Marks an article as read and notifies everyone. */
- (void)markArticleAsReadAndNotify:(Article *)article {
	if (![article.read boolValue]) {
		NSError *error;
		article.read = [NSNumber numberWithBool:TRUE];
		[managedObjectContext save:&error];
		
		// Notify everyone and let them update themselves
		NSDictionary *info = [NSDictionary dictionaryWithObject:article forKey:@"article"];
		[[NSNotificationCenter defaultCenter] postNotificationName:BBNotificationArticleRead object:self userInfo:info];
	}		
}


#pragma mark -
#pragma mark Notifications

/** Invoked when new articles are added to a feed. */
- (void)onArticlesAdded:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSManagedObject *feed = [userInfo objectForKey:@"feed"];
	if ([guide.feeds containsObject:feed]) {
		[self.tableView reloadData];
		[self updateBadge];
	}
}

/** Invoked when an article is read. */
- (void)onArticleRead:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	Article *article = [userInfo objectForKey:@"article"];
	NSManagedObject *feed = article.feed;
	if ([guide.feeds containsObject:feed]) {
		// Update row
		@try {
			NSIndexPath *path = [[self fetchedResultsController] indexPathForObject:article];
			[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
		} @catch (NSException *ex) {
			NSLog(@"Failed to update read article: %@", ex);
		}
		
		[self updateBadge];
	}
}

#pragma mark -
#pragma mark Navigation

/** Invoked to move on to the next article. */
- (void)onNextArticle:(ArticleViewController *)articleViewController {
	[self onNextArticle:articleViewController withDelta:1];
}

/** Invoked to move on to the previous article. */
- (void)onPreviousArticle:(ArticleViewController *)articleViewController {
	[self onNextArticle:articleViewController withDelta:-1];
}

- (void)onNextArticle:(ArticleViewController *)articleViewController withDelta:(int)delta {
	Article *articleToSelect = nil;
	NSArray *articles = [fetchedResultsController fetchedObjects];
	
	int nextIndex = -1;
	Article *currentArticle  = articleViewController.article;
	if (currentArticle == nil) {
		// Try first
		nextIndex = delta == 1 ? 0 : [articles count] - 1;
	} else {
		nextIndex = [articles indexOfObject:currentArticle] + delta;
	}
	
	if (nextIndex >= 0 && [articles count] > nextIndex) articleToSelect = [articles objectAtIndex:nextIndex];
	if (articleToSelect != nil) {
		articleViewController.article = articleToSelect;
		[self markArticleAsReadAndNotify:articleToSelect];
	}
}

@end

