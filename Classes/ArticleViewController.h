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
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (id)initWithArticle:(Article *)anArticle;

@end
