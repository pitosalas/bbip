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
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// TODO: Handle the error...
	}
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
	cell.detailTextLabel.text	= article.briefBody;
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	Article *article = (Article *)[fetchedResultsController objectAtIndexPath:indexPath];
	NSString *cellDetailText = article.briefBody;
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

	ArticleViewController *articleViewController = [[ArticleViewController alloc] initWithArticle:article];	
	[self.navigationController pushViewController:articleViewController animated:YES];
	[articleViewController release];
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


@end

