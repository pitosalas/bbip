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

@implementation ArticleViewController

@synthesize webView;

- (id)initWithArticle:(Article *)anArticle {
	if (self = [super initWithNibName:@"ArticleViewController" bundle:nil]) {
		article = [anArticle retain];
		self.hidesBottomBarWhenPushed = YES;
		
		currentFontBias = [[NSUserDefaults standardUserDefaults] integerForKey:BBSettingCurrentFontBias];
	}
	
	return self;
}

- (void)dealloc {
	[article release];
    [super dealloc];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSString *metaHTML  = [NSString stringWithFormat:@"<div id='bbip-meta'><div id='bbip-feed-title'>%@</div><div id='bbip-article-title'>%@</div></div>", [article.feed valueForKey:@"name"], article.title];
	NSString *style		= [NSString stringWithFormat:@"#bbip-meta { margin-bottom: 1em; } #bbip-feed-title { text-transform:uppercase; font-family:Helvetica; font-size: 14px; } #bbip-article-title { font-family: Georgia; font-size: 20px; } body { -webkit-text-size-adjust: %d%% }", currentFontBias];
	NSString *html		= [NSString stringWithFormat:@"<html><head><style type='text/css'>%@</style></head><body>%@<div id='bbip-article'>%@</div></body></html>", style, metaHTML, article.body];

	[webView loadHTMLString:html baseURL:article.baseURL];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
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
	NSLog(@"%@", [webView stringByEvaluatingJavaScriptFromString:javascript]);
}

@end