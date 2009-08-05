// 
//  Article.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Article.h"


@implementation Article 

@dynamic read;
@dynamic title;
@dynamic url;
@dynamic pubDate;
@dynamic body;
@dynamic feed;

- (NSString *)briefBody {
	// TODO: 3 setences, plain text
	return @"Something incredibly long and informative. Something incredibly long and informative. Something incredibly long and informative. Something.";
}

@end
