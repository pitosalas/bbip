// 
//  Article.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Article.h"
#import "Guide.h"

static NSString *codes[] = {
	@"&nbsp;",   @"&iexcl;",  @"&cent;",   @"&pound;",  @"&curren;", @"&yen;",    @"&brvbar;",
	@"&sect;",   @"&uml;",    @"&copy;",   @"&ordf;",   @"&laquo;",  @"&not;",    @"&shy;",
    @"&reg;",    @"&macr;",   @"&deg;",    @"&plusmn;", @"&sup2;",   @"&sup3;",   @"&acute;",
    @"&micro;",  @"&para;",   @"&middot;", @"&cedil;",  @"&sup1;",   @"&ordm;",   @"&raquo;",
    @"&frac14;", @"&frac12;", @"&frac34;", @"&iquest;", @"&Agrave;", @"&Aacute;", @"&Acirc;",
	@"&Atilde;", @"&Auml;",   @"&Aring;",  @"&AElig;",  @"&Ccedil;", @"&Egrave;", @"&Eacute;",
    @"&Ecirc;",  @"&Euml;",   @"&Igrave;", @"&Iacute;", @"&Icirc;",  @"&Iuml;",   @"&ETH;",
    @"&Ntilde;", @"&Ograve;", @"&Oacute;", @"&Ocirc;",  @"&Otilde;", @"&Ouml;",   @"&times;",
    @"&Oslash;", @"&Ugrave;", @"&Uacute;", @"&Ucirc;",  @"&Uuml;",   @"&Yacute;", @"&THORN;",
    @"&szlig;",  @"&agrave;", @"&aacute;", @"&acirc;",  @"&atilde;", @"&auml;",   @"&aring;",
    @"&aelig;",  @"&ccedil;", @"&egrave;", @"&eacute;", @"&ecirc;",  @"&euml;",   @"&igrave;",
    @"&iacute;", @"&icirc;",  @"&iuml;",   @"&eth;",    @"&ntilde;", @"&ograve;", @"&oacute;",
    @"&ocirc;",  @"&otilde;", @"&ouml;",   @"&divide;", @"&oslash;", @"&ugrave;", @"&uacute;",
	@"&ucirc;",  @"&uuml;",   @"&yacute;", @"&thorn;",  @"&yuml;",
	@"&quot;",   @"&apos;",   @"&amp;",    @"&lt;",     @"&gt;" };

static int customCodes[] = { 34, 39, 38, 60, 62 };

@implementation Article 

@dynamic read;
@dynamic title;
@dynamic url;
@dynamic pubDate;
@dynamic body;
@dynamic feed;
@dynamic brief;

/** Sets read status and updates underlying guides. */
- (void)setRead:(NSNumber *)read {
	NSNumber *wasRead = self.read;
	
	[self willChangeValueForKey:@"read"];
	[self setPrimitiveValue:read forKey:@"read"];
	[self didChangeValueForKey:@"read"];
	
	// Update all feeds and guides
	if (![wasRead boolValue] && [read boolValue]) {
		NSSet *guides = [self.feed valueForKeyPath:@"guides"];
		for (Guide *guide in guides) {
			guide.unreadCount = [NSNumber numberWithInt:([guide.unreadCount intValue] - 1)];
		}
	}
}

/** Makes a brief version automatically. */
- (void)setBody:(NSString *)body {
	[self willChangeValueForKey:@"body"];
	[self setPrimitiveValue:body forKey:@"body"];
	[self didChangeValueForKey:@"body"];
	
	[self willChangeValueForKey:@"brief"];
	NSString *plainText = [Article plainTextFromHTML:self.body];
	NSString *value     = [[Article decodeCharacterEntities:[Article sentencesFromText:plainText sentences:3]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	[self setPrimitiveValue:value forKey:@"brief"];
	[self didChangeValueForKey:@"brief"];
}

- (NSURL *)baseURL {
	return [NSURL URLWithString:self.url];
}

- (void)dealloc {
	[super dealloc];
}

/** Creates a plain text string from the HTML. */
+ (NSString *)plainTextFromHTML:(NSString *)html {
	if ([html rangeOfString:@"<"].location == NSNotFound) return html;
	
	NSScanner *scanner = [NSScanner scannerWithString:html];
	NSString  *text;

	while ([scanner isAtEnd] == NO) {
		[scanner scanUpToString:@"<" intoString:NULL];
		[scanner scanUpToString:@">" intoString:&text];
		html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
	}

	return html;
}

/** Returns up to given number of sentences from the string. */
+ (NSString *)sentencesFromText:(NSString *)plainText sentences:(int)sentences {
	NSScanner *scanner = [NSScanner scannerWithString:plainText];
	NSCharacterSet *terminators = [NSCharacterSet characterSetWithCharactersInString:@".!?"];
	while (sentences > 0 && [scanner isAtEnd] == NO) {
		[scanner scanUpToCharactersFromSet:terminators intoString:NULL];
		[scanner scanCharactersFromSet:terminators intoString:NULL];
		sentences--;
	}

	return [scanner isAtEnd] ? plainText : [plainText substringToIndex:[scanner scanLocation]];
}

/** Decodes entities into real characters. */
+ (NSString *)decodeCharacterEntities:(NSString *)source {
	if (!source) return nil;
	
	if ([source rangeOfString: @"&"].location == NSNotFound) return source;

	NSMutableString *escaped = [NSMutableString stringWithString:source];
		
	// Html
	int i;
	for (i = 0; i < sizeof(codes) / sizeof(NSString *); i++) {
		NSRange range = [source rangeOfString:codes[i]];
		if (range.location != NSNotFound) {
			int code = 160 + i;
			if (code > 255) code = customCodes[code - 256];
			[escaped replaceOccurrencesOfString:codes[i]
									 withString:[NSString stringWithFormat:@"%C", code]
										options:NSLiteralSearch
										  range:NSMakeRange(0, [escaped length])];
		}
	}
	
	// Decimal & Hex
	NSRange start, finish, searchRange = NSMakeRange(0, [escaped length]);
		
	i = 0;
	while (i < [escaped length]) {
		start  = [escaped rangeOfString:@"&#" options:NSCaseInsensitiveSearch range:searchRange];
		finish = [escaped rangeOfString:@";"  options:NSCaseInsensitiveSearch range:searchRange];
			
		if (start.location != NSNotFound && finish.location != NSNotFound && finish.location > start.location) {
			NSRange entityRange = NSMakeRange(start.location, (finish.location - start.location) + 1);
			NSString *entity    = [escaped substringWithRange:entityRange];
			NSString *value     = [entity substringWithRange:NSMakeRange(2, [entity length] - 2)];
				
			[escaped deleteCharactersInRange:entityRange];
				
			if ([value hasPrefix:@"x"]) {
				unsigned tempInt = 0;
				NSScanner *scanner = [NSScanner scannerWithString:[value substringFromIndex:1]];
				[scanner scanHexInt:&tempInt];
				[escaped insertString:[NSString stringWithFormat:@"%C", tempInt] atIndex:entityRange.location];
			} else {
				[escaped insertString:[NSString stringWithFormat: @"%C", [value intValue]] atIndex: entityRange.location];
			}
				
			i = start.location;
		} else {
			i++;
		}
			
		searchRange = NSMakeRange(i, [escaped length] - i);
	}
		
	return escaped;
}

@end
