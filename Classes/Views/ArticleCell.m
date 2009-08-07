//
//  ArticleCell.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ArticleCell.h"

float const ARTICLE_CELL_TEXTLABEL_FONT_SIZE		= 16.0;
float const ARTICLE_CELL_DETAILTEXTLABEL_FONT_SIZE	= 12.0;

@implementation ArticleCell

- (id)initWithIdentifier:(NSString *)identifier {
	if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier]) {
		self.detailTextLabel.numberOfLines = 0;
		
		// Configure fonts
		self.textLabel.font			= [UIFont boldSystemFontOfSize:16.0];
		self.detailTextLabel.font	= [UIFont systemFontOfSize:12.0];
	}
	
	return self;
}

/**
 * Fix the layout of subviews.
 */
- (void) layoutSubviews {
	[super layoutSubviews];

	self.textLabel.frame       = CGRectMake(self.textLabel.frame.origin.x, 
                                            4.0, 
                                            self.textLabel.frame.size.width, 
                                            self.textLabel.frame.size.height);
	self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x, 
											8.0 + self.textLabel.frame.size.height, 
											self.detailTextLabel.frame.size.width, 
											self.detailTextLabel.frame.size.height);
}

@end
