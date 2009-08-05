//
//  GuidesTabController.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GuidesTabController.h"
#import "GuideViewController.h"
#import "ArticleViewController.h"
#import "Article.h"

@implementation GuidesTabController

@synthesize managedObjectContext;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext {
	if (self = [super init]) {
		self.delegate = self;
		self.managedObjectContext = aManagedObjectContext;
		// Load the list of guides and create controllers for them
		self.viewControllers = [self loadAndCreateGuideControllers];
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.title = [[self.viewControllers objectAtIndex:0] title];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[managedObjectContext release];
    [super dealloc];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	self.title = viewController.title;
}

/**
 * Loads the list of guides and creates the controllers for them.
 * Controllers don't load their data before they are actually shown, so it's cheap.
 */
- (NSArray *)loadAndCreateGuideControllers {
	NSMutableArray *controllers = [[NSMutableArray alloc] init];
	GuideViewController *guideController;
	
	// Create the fetch request
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity  = [NSEntityDescription entityForName:@"Guide" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSError *error;
	NSArray *guides = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	for (Guide *guide in guides) {
		guideController = [[GuideViewController alloc] initWithGuide:guide andSelectionDelegate:self];
		guideController.managedObjectContext = self.managedObjectContext;
		
		[controllers addObject:guideController];
		
		[guideController release];
	}
	
	[fetchRequest release];
	[sortDescriptor release];
	
	return [controllers autorelease];
}

- (void) articleDidSelect:(Article *)article {
	ArticleViewController *articleViewController = [[ArticleViewController alloc] initWithArticle:article];	
	[self.navigationController pushViewController:articleViewController animated:YES];
	[articleViewController release];
}

@end
