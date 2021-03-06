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
#import "Constants.h"

@implementation GuidesTabController

@synthesize managedObjectContext;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext {
	if (self = [super init]) {
		self.managedObjectContext = aManagedObjectContext;

		// Load the list of guides and create controllers for them
		self.viewControllers = [self loadAndCreateGuideControllers];

		// Set the style of the nav bar on the More... page and prepare the callback for the
		// Configure page.
		self.moreNavigationController.navigationBar.barStyle = UIBarStyleBlack;
		self.delegate = self;
	}
	return self;
}

- (void)dealloc {
	[managedObjectContext release];
    [super dealloc];
}

/** Set the style of the tab bar on the "Configure" page (when click Edit on the More... page). */
- (void)tabBarController:(UITabBarController *)tabBarController willBeginCustomizingViewControllers:(NSArray *)viewControllers {
    UIView *views = [tabBarController.view.subviews objectAtIndex:1];
    UINavigationBar *navBar = [[views subviews] objectAtIndex:0];
    navBar.barStyle = UIBarStyleBlack;
}

- (void)viewWillAppear:(BOOL)animated {
	// Select the previously selected guide
	int index = [[NSUserDefaults standardUserDefaults] integerForKey:BBSettingSelectedGuide];
	if ([self.viewControllers count] > index) {
		UIViewController *controller = [self.viewControllers objectAtIndex:index];
		self.selectedViewController = controller;
	}
	
	[super viewWillAppear:animated];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	self.title = viewController.title;
	[[NSUserDefaults standardUserDefaults] setInteger:self.selectedIndex forKey:BBSettingSelectedGuide];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	BOOL articleView = NO;
	
	UIViewController *viewController = self.selectedViewController;
	if ([viewController isKindOfClass:[UINavigationController class]]) {
		UINavigationController *controller = (UINavigationController *)viewController;
		articleView = controller != nil && [controller.topViewController isKindOfClass:[ArticleViewController class]];
	}
	
    return articleView || (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/**
 * Loads the list of guides and creates the controllers for them.
 * Controllers don't load their data before they are actually shown, so it's cheap.
 */
- (NSArray *)loadAndCreateGuideControllers {
	NSMutableArray *controllers = [[NSMutableArray alloc] init];
	GuideViewController *guideController;
	UINavigationController *navigationController;
	
	// Create the fetch request
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity  = [NSEntityDescription entityForName:@"Guide" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	
	NSError *error;
	NSArray *guides = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	for (Guide *guide in guides) {
		guideController = [[GuideViewController alloc] initWithGuide:guide];
		guideController.managedObjectContext = self.managedObjectContext;
		
		navigationController = [[UINavigationController alloc] initWithRootViewController:guideController];
		navigationController.navigationBar.barStyle = UIBarStyleBlack;
		
		[controllers addObject:navigationController];
		
		[guideController release];
		[navigationController release];
	}
	
	[fetchRequest release];
	[sortDescriptor release];
	
	return [controllers autorelease];
}

@end
