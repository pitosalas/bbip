//
//  Article.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Article :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSDate * pubDate;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, readonly) NSString * briefBody;
@property (nonatomic, retain) NSManagedObject * feed;

@end



