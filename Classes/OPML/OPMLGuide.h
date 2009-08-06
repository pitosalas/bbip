//
//  OPMLGuide.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OPMLFeed;

@interface OPMLGuide : NSObject {
	NSString		*name;
	NSString		*iconName;
	NSMutableArray	*feeds;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *iconName;
@property (nonatomic, readonly) NSArray *feeds;

- (id)initWithName:(NSString *)aName iconName:(NSString *)anIconName;
- (void)addFeed:(OPMLFeed *)feed;

@end
