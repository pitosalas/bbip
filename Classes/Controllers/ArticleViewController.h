//
//  ArticleViewController.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Article;

@interface ArticleViewController : UIViewController {
	UIWebView	*webView;
	Article		*article;
	int			currentFontBias;
	UIToolbar	*toolbar;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

- (id)initWithArticle:(Article *)anArticle;

- (IBAction)smallerFont;
- (IBAction)largerFont;

@end


@interface ArticleViewController (private)

/** Changes the font bias by given delta. */
- (void)changeFontBiasBy:(int)delta;

@end
