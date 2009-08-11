//
//  Article.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface Article : NSManagedObject {
}

@property (nonatomic, retain) NSNumber			*read;
@property (nonatomic, retain) NSString			*title;
@property (nonatomic, retain) NSString			*url;
@property (nonatomic, retain) NSDate			*pubDate;
@property (nonatomic, retain) NSString			*body;
@property (nonatomic, retain) NSString			*brief;
@property (nonatomic, retain) NSManagedObject	*feed;

@property (nonatomic, readonly) NSURL			*baseURL;

/** Creates a plain text string from the HTML. */
+ (NSString *)plainTextFromHTML:(NSString *)html;

/** Returns up to given number of sentences from the string. */
+ (NSString *)sentencesFromText:(NSString *)plainText sentences:(int)sentences;

/** Decodes entities into real characters. */
+ (NSString *)decodeCharacterEntities:(NSString *)source;

@end



