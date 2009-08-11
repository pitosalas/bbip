//
//  Guide.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Guide :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString	*name;
@property (nonatomic, retain) NSString	*iconName;
@property (nonatomic, retain) NSSet		*feeds;
@property (nonatomic, retain) NSNumber  *unreadCount;

@end


@interface Guide (CoreDataGeneratedAccessors)

- (void)addFeedsObject:(NSManagedObject *)value;
- (void)removeFeedsObject:(NSManagedObject *)value;
- (void)addFeeds:(NSSet *)value;
- (void)removeFeeds:(NSSet *)value;

@end

