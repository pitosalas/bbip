//
//  RSSItem.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RSSItem : NSObject {
	NSString *title;
	NSString *url;
	NSString *body;
	NSDate   *pubDate;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSDate   *pubDate;

@end
