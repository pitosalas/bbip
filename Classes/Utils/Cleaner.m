//
//  Cleaner.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Cleaner.h"
#import "Constants.h"

@implementation Cleaner

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context {
	if (self = [super init]) {
		managedObjectContext = [context retain];
	}
	return self;
}

- (void)dealloc {
	[managedObjectContext release];
	[super dealloc];
}

/** Cleans the database. */
- (void) performCleanup {
	NSEntityDescription *articleEntity = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:managedObjectContext];
	NSFetchRequest *req = [[NSFetchRequest alloc] init];
	[req setEntity:articleEntity];
	[req setPredicate:[NSPredicate predicateWithFormat:@"(read = 1 AND pubDate < %@) OR pubDate < %@", [self borderReadArticleDate], [self borderUnreadArticleDate]]];
	
	NSArray *articles = [managedObjectContext executeFetchRequest:req error:nil];
	if ([articles count] > 0) {
		for (NSManagedObject *article in articles) {
			[managedObjectContext deleteObject:article];
		}
		[managedObjectContext save];
	}
	
	[req release];
}


#pragma mark -
#pragma mark Private

/** Border date for read articles. Older articles have to be removed. */
- (NSDate *)borderReadArticleDate {
	int interval = [[NSUserDefaults standardUserDefaults] integerForKey:BBSettingReadArticleAge];
	return [NSDate dateWithTimeIntervalSinceNow:-interval];
}

/** Border date for unread articles. Older articles have to be removed. */
- (NSDate *)borderUnreadArticleDate {
	int interval = [[NSUserDefaults standardUserDefaults] integerForKey:BBSettingUnreadArticleAge];
	return [NSDate dateWithTimeIntervalSinceNow:-interval];
}

@end
