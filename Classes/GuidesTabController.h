//
//  GuidesTabController.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuidesTabController : UITabBarController <UITabBarControllerDelegate> {
	NSManagedObjectContext		*managedObjectContext;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (NSArray *)loadAndCreateGuideControllers;

@end
