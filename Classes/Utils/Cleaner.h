//
//  Cleaner.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Cleaner : NSObject {
	NSManagedObjectContext *managedObjectContext;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

/** Cleans the database. */
- (void)performCleanup;

@end



@interface Cleaner (private)

/** Border date for read articles. Older articles have to be removed. */
- (NSDate *)borderReadArticleDate;

/** Border date for unread articles. Older articles have to be removed. */
- (NSDate *)borderUnreadArticleDate;

@end
