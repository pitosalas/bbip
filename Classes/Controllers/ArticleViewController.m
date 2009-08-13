//
//  ArticleViewController.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ArticleViewController.h"
#import "Article.h"
#import "Constants.h"
#import "BBWebView.h"

@implementation ArticleViewController

@synthesize webView, toolbar, article, navDelegate;

- (id)initWithArticle:(Article *)anArticle {
	if (self = [super initWithNibName:@"ArticleViewController" bundle:nil]) {
		article = [anArticle retain];
		self.hidesBottomBarWhenPushed = YES;
		
		currentFontBias = [[NSUserDefaults standardUserDefaults] integerForKey:BBSettingCurrentFontBias];
	}
	
	return self;
}

- (void)dealloc {
	self.article = nil;
    [super dealloc];
}

- (void)viewDidLoad {
	segmentedButtons = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:[UIImage imageNamed:@"left.png"], [UIImage imageNamed:@"right.png"], nil]];
	segmentedButtons.momentary = YES;
	segmentedButtons.segmentedControlStyle = UISegmentedControlStyleBar;
	[segmentedButtons addTarget:self action:@selector(onButtonNavigation) forControlEvents:UIControlEventValueChanged];
	self.navigationItem.titleView = segmentedButtons;
	
	webView.navDelegate = self;
	toolbar.hidden = YES;
	
	[self setArticle:article];
    [super viewDidLoad];
}

- (void)setArticle:(Article *)anArticle {
	[article autorelease];
	article = [anArticle retain];
	
	if (article != nil) {
		NSString *metaHTML  = [NSString stringWithFormat:@"<div id='bbip-meta'><div id='bbip-feed-title'>%@</div><div id='bbip-article-title'>%@</div></div>", [article.feed valueForKey:@"name"], article.title];
		NSString *style		= [NSString stringWithFormat:@"#bbip-meta { margin-bottom: 1em; } #bbip-feed-title { text-transform:uppercase; font-family:Helvetica; font-size: 14px; } #bbip-article-title { font-family: Georgia; font-size: 20px; } body { -webkit-text-size-adjust: %d%% }", currentFontBias];
		NSString *html		= [NSString stringWithFormat:@"<html><head><style type='text/css'>%@</style></head><body>%@<div id='bbip-article'>%@</div></body></html>", style, metaHTML, article.body];
		
		[webView loadHTMLString:html baseURL:article.baseURL];
	} else {
		[webView loadHTMLString:@"" baseURL:nil];
	}
}

- (void)viewDidUnload {
	self.webView = nil;
	self.toolbar = nil;
	[segmentedButtons release];
	segmentedButtons = nil;
}

#pragma mark -
#pragma mark Font size

/** Invoked when the user changes the font size. */
- (IBAction)smallerFont {
	[self changeFontBiasBy:-10];
}

/** Invoked when the user changes the font size. */
- (IBAction)largerFont {
	[self changeFontBiasBy:10];
}

/** Changes the font bias by given delta. */
- (void)changeFontBiasBy:(int)delta {
	currentFontBias += delta;
	if (currentFontBias > 400) currentFontBias = 400;
	if (currentFontBias < 10) currentFontBias = 10;

	// Save preference
	[[NSUserDefaults standardUserDefaults] setInteger:currentFontBias forKey:BBSettingCurrentFontBias];
	
	NSString *javascript = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='%d%%'", currentFontBias];
	[webView stringByEvaluatingJavaScriptFromString:javascript];
}

#pragma mark -
#pragma mark Navigation

/** Invoked when someone moves to the next article. */
- (void)onNextArticle {
	SEL action = @selector(onNextArticle:);
	
	if ([navDelegate respondsToSelector:action]) {
		[navDelegate performSelector:action withObject:self];
	}
}

/** Invoked when someone moves to the previous article. */
- (void)onPreviousArticle {
	SEL action = @selector(onPreviousArticle:);
	
	if ([navDelegate respondsToSelector:action]) {
		[navDelegate performSelector:action withObject:self];
	}
}

/** Invoked when the user touches segmented navigation buttons in the title bar. */
- (void)onButtonNavigation {
	if (segmentedButtons.selectedSegmentIndex == 0) [self onPreviousArticle]; else [self onNextArticle];
}

/** Invoked when someone touches the middle section. */
- (void)onTouch {
	[toolbar setHidden:!toolbar.hidden];
}

@end
