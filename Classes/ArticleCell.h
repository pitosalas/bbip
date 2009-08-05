//
//  ArticleCell.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

extern float const ARTICLE_CELL_TEXTLABEL_FONT_SIZE;
extern float const ARTICLE_CELL_DETAILTEXTLABEL_FONT_SIZE;

@interface ArticleCell : UITableViewCell {
}

- (id)initWithIdentifier:(NSString *)identifier;

@end
