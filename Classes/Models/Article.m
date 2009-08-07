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
	if (!briefBody) {
		// TODO: 3 setences, plain text
		briefBody = @"Something incredibly long and informative. Something incredibly long and informative. Something incredibly long and informative. Something.";
		[briefBody retain];
	}
	
	return briefBody;
}

- (NSString *)fullHTML {
	if (!fullHTML) {
		// TODO: Full HTML
		fullHTML = [NSString stringWithFormat:@"<html><head><style type='text/css'>#bbip-meta { margin-bottom: 1em; } #bbip-feed-title { text-transform:uppercase; font-family:Helvetica; font-size: 14px; } #bbip-article-title { font-family: Georgia; font-size: 20px; } </style></head><body><div id='bbip-meta'><div id='bbip-feed-title'>%@</div><div id='bbip-article-title'>%@</div></div>%@</body></html>", 
					[self.feed valueForKey:@"name"], self.title, self.body];
		[fullHTML retain];
	}
	
	return fullHTML;
}

- (NSURL *)baseURL {
	return [NSURL URLWithString:self.url];
}

- (void)dealloc {
	[briefBody release];
	[fullHTML release];
	[super dealloc];
}

@end
