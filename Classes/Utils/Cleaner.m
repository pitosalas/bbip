//
//  Cleaner.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Cleaner.h"

@implementation Cleaner

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context defaults:(NSDictionary *)aDefaults{
	if (self = [super init]) {
		managedObjectContext = [context retain];
		defaults = [aDefaults retain];
	}
	return self;
}

- (void)dealloc {
	[defaults release];
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
	NSNumber *interval = [defaults objectForKey:KEY_MAX_READ_AGE];
	return [NSDate dateWithTimeIntervalSinceNow:-[interval intValue]];
}

/** Border date for unread articles. Older articles have to be removed. */
- (NSDate *)borderUnreadArticleDate {
	NSNumber *interval = [defaults objectForKey:KEY_MAX_UNREAD_AGE];
	return [NSDate dateWithTimeIntervalSinceNow:-[interval intValue]];
}

@end
