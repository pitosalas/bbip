//
//  ArticleViewController.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBWebView, Article;

@interface ArticleViewController : UIViewController {
	BBWebView	*webView;
	Article		*article;
	int			currentFontBias;
	UIToolbar	*toolbar;
	id			navDelegate;
}

@property (nonatomic, retain) IBOutlet BBWebView *webView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) Article *article;
@property (nonatomic, assign) id navDelegate;

- (id)initWithArticle:(Article *)anArticle;

- (IBAction)smallerFont;
- (IBAction)largerFont;

@end


@interface ArticleViewController (private)

/** Changes the font bias by given delta. */
- (void)changeFontBiasBy:(int)delta;

@end
