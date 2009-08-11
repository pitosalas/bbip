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
		self.tabBarItem = [[[UITabBarItem alloc] 
							initWithTitle:guide.name 
							image:[UIImage imageNamed:[NSString stringWithFormat:@"images/%@.png", guide.iconName]] 
							tag:0] autorelease];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onArticlesAdded:) name:BBNotificationArticlesAdded object:nil]; 
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onArticleRead:) name:BBNotificationArticleRead object:nil]; 
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// TODO: Handle the error...
	} else {
		// Count read / unread
		[self updateBadge];
	}
}

/** Updates the badge. */
- (void)updateBadge {
	int unread = [guide.unreadCount intValue];
	self.tabBarItem.badgeValue = unread > 0 ? [NSString stringWithFormat:@"%i", unread] : nil;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
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
	
	cell.textLabel.textColor 	= article.read ? [UIColor darkGrayColor] : [UIColor blackColor];
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	Article *article = (Article *)[fetchedResultsController objectAtIndexPath:indexPath];
	NSString *cellDetailText = article.brief;
	NSString *cellText = article.title;

	// The width subtracted from the tableView frame depends on:
	// 40.0 for detail accessory
	CGSize constraintSize = CGSizeMake(tableView.frame.size.width - 20.0, CGFLOAT_MAX);
	CGSize labelSize      = [cellText       sizeWithFont:[UIFont boldSystemFontOfSize:BBArticleCellTextFontSize] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	CGSize detailSize     = [cellDetailText sizeWithFont:[UIFont systemFontOfSize:BBArticleCellDetailFontSize] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	
	return labelSize.height + detailSize.height + 12;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Article *article = (Article *)[fetchedResultsController objectAtIndexPath:indexPath];
	
	// Show article panel
	ArticleViewController *articleViewController = [[ArticleViewController alloc] initWithArticle:article];	
	[self.navigationController pushViewController:articleViewController animated:YES];
	[articleViewController release];

	// Mark article as read and update the row
	if (!article.read) {
		NSError *error;
		article.read = [NSNumber numberWithBool:TRUE];
		[managedObjectContext save:&error];
		
		// Notify everyone and let them update themselves
		NSDictionary *info = [NSDictionary dictionaryWithObject:article forKey:@"article"];
		[[NSNotificationCenter defaultCenter] postNotificationName:BBNotificationArticleRead object:self userInfo:info];
	}		
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

/*
// NSFetchedResultsControllerDelegate method to notify the delegate that all section and object changes have been processed. 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView reloadData];
}
*/

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

- (void)dealloc {
	[guide release];
	[fetchedResultsController release];
	[managedObjectContext release];
    [super dealloc];
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
		
		// Update badge
		[self updateBadge];
	}
}

@end

