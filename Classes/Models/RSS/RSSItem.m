//
//  RSSItem.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RSSItem.h"

static NSString* DateFormats[] = {
	@"EEE, dd MMM yyyy HH:mm:ss z",
	@"EEE, dd MMM yyyy HH:mm zzzz",
	@"yyyy-MM-dd'T'HH:mm:ssZ",
	@"yyyy-MM-dd'T'HH:mm:ss.SSSzzzz",	// Blogger Atom feed has millisecs also
	@"yyyy-MM-dd'T'HH:mm:sszzzz",
	@"yyyy-MM-dd'T'HH:mm:ss z",
	@"yyyy-MM-dd'T'HH:mm:ssz",			// ISO_8601
	@"yyyy-MM-dd'T'HH:mm:ss",
	@"yyyy-MM-dd'T'HHmmss.SSSz",
	@"yyyy-MM-dd'T'HH:mm:ss",
	@"yyyy-MM-dd'T'HH:mmzzzz",
	@"yyyy-MM-dd",
	NULL };

@implementation RSSItem

@synthesize title, body, url, pubDate;

/** Attempts to convert the string date representation into a real object. */
- (NSDate *)pubDateObject {
	NSDate *date = nil;
	
	if (self.pubDate == nil) return nil;
	
	NSString *sdate = self.pubDate;
	NSRange sixLastChars = NSMakeRange([sdate length] - 6, 6);
	if ([sdate rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"-+"] options:NSLiteralSearch range:sixLastChars].location != NSNotFound &&
		[sdate rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@":"]  options:NSLiteralSearch range:sixLastChars].location != NSNotFound) {
		if (![[sdate substringWithRange:NSMakeRange([sdate length] - 9, 3)] caseInsensitiveCompare:@"gmt"] == NSOrderedSame) {
			NSMutableString *mdate = [NSMutableString stringWithString:sdate];
			[mdate replaceOccurrencesOfString:@":" withString:@"" options:NSLiteralSearch range:sixLastChars];
			NSLog(@"--> %@", mdate);
			sdate = mdate;
		}
	}
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	
	NSString **format = DateFormats;
	while (*format && date == nil) {
		formatter.dateFormat = *format;
		date = [formatter dateFromString:sdate];
		if ([date timeIntervalSince1970] == 0) date = nil;
		format++;
	}
	
	[formatter release];
	
	return date;
}

@end
