//
//  OPMLFeed.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OPMLFeed : NSObject {
	NSString	*title;
	NSString	*xmlURL;
	NSString	*htmlURL;
	NSArray		*readArticleKeys;
}

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *xmlURL;
@property (nonatomic, readonly) NSString *htmlURL;
@property (nonatomic, readonly) NSArray  *readArticleKeys;

- (id)initWithTitle:(NSString *)aTitle xmlURL:(NSString *)anXmlURL htmlURL:(NSString *)anHtmlURL readArticleKeys:(NSArray *)aReadArticleKeys;

@end