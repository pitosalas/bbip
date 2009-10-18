//
//  Feed.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 10/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Guide;
@class Article;

@interface Feed : NSManagedObject {
}

@property (nonatomic, retain) NSNumber	*handlingType;
@property (nonatomic, retain) NSString	*url;
@property (nonatomic, retain) NSString	*latestArticleKey;
@property (nonatomic, retain) NSString	*name;
@property (nonatomic, retain) NSString	*incomingReadArticlesKeys;
@property (nonatomic, retain) NSDate	*updatedOn;
@property (nonatomic, retain) NSSet		*guides;
@property (nonatomic, retain) NSSet		*articles;

/** Marks articles as read with incoming keys. */
- (void) markArticlesAsReadWithIncomingKeys;

/** Returns true if the article match key is among the recorded read keys. */
- (BOOL) knowsArticleAsRead:(Article *)article;

/** Returns the array with article keys. */
- (NSArray *) getReadKeys;

@end


@interface Feed (CoreDataGeneratedAccessors)
- (void)addGuidesObject:(Guide *)value;
- (void)removeGuidesObject:(Guide *)value;
- (void)addGuides:(NSSet *)value;
- (void)removeGuides:(NSSet *)value;

- (void)addArticlesObject:(Article *)value;
- (void)removeArticlesObject:(Article *)value;
- (void)addArticles:(NSSet *)value;
- (void)removeArticles:(NSSet *)value;
@end

