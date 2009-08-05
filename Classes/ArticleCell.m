//
//  ArticleCell.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ArticleCell.h"


@implementation ArticleCell

- (id)initWithIdentifier:(NSString *)identifier {
	if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier]) {
		self.detailTextLabel.numberOfLines = 0;
	}
	
	return self;
}

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
