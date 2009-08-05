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

	// Set up the edit and add buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Handle the error...
	}
}


- (void)insertNewObject {
	// Create a new instance of the entity managed by the fetched results controller.
	NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
	NSEntityDescription *entity = [[fetchedResultsController fetchRequest] entity];
	NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
	
	// If appropriate, configure the new managed object.
	[newManagedObject setValue:@"Test" forKey:@"name"];
	
	// Save the context.
    NSError *error;
    if (![context save:&error]) {
		// Handle the error...
    }

    [self.tableView reloadData];
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
	CGSize constraintSize = CGSizeMake(tableView.frame.size.width - 40.0, CGFLOAT_MAX);
	CGSize labelSize      = [cellText       sizeWithFont: [UIFont boldSystemFontOfSize:ARTICLE_CELL_TEXTLABEL_FONT_SIZE] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	CGSize detailSize     = [cellDetailText sizeWithFont: [UIFont systemFontOfSize:ARTICLE_CELL_DETAILTEXTLABEL_FONT_SIZE] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	
	return labelSize.height + detailSize.height;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
    // NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    // Pass the selected object to the new view controller.
    /// ...
	// [self.navigationController pushViewController:anotherViewController animated:YES];
	// [anotherViewController release];
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

