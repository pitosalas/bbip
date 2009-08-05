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


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

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
    
	// Configure the cell.

	Article *article = (Article *)[fetchedResultsController objectAtIndexPath:indexPath];

	cell.textLabel.text = article.title;
	cell.detailTextLabel.text  = article.briefBody;
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	Article *article = (Article *)[fetchedResultsController objectAtIndexPath:indexPath];
	NSString *cellDetailText = article.briefBody;
	NSString *cellText = article.title;

	// The width subtracted from the tableView frame depends on:
	// 40.0 for detail accessory
	// Width of icon image
	// Editing width
	// I don't think you can count on the cell being properly laid out here, so you've
	// got to hard code it based on the state of the table.
	int frameWidth = tableView.frame.size.width;
	NSLog(@"Frame=%d", frameWidth);
	CGSize constraintSize = CGSizeMake(tableView.frame.size.width - 40.0, CGFLOAT_MAX);
	CGSize labelSize      = [cellText       sizeWithFont: [UIFont systemFontOfSize:20.0] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	CGSize detailSize     = [cellDetailText sizeWithFont: [UIFont systemFontOfSize:14.0] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	
	return labelSize.height + detailSize.height + 12;
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


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		[context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
		
		// Save the context.
		NSError *error;
		if (![context save:&error]) {
			// Handle the error...
		}
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    
    /*
	 Set up the fetched results controller.
	*/

	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ANY feed.guides == %@", guide]];
	
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
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

