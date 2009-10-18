//
//  RSSItem.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RSSItem.h"
#import "NSString+JavaHash.h"

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

@synthesize title, body, url, pubDate, pubDateObject;

- (void)setPubDate:(NSString *)date {
	[pubDate autorelease];
	pubDate = [date retain];
	
	[pubDateObject autorelease];
	pubDateObject = [[RSSItem dateFromString:date] retain];
}

- (void)dealloc {
	title	= nil;
	body	= nil;
	url		= nil;
	pubDate	= nil;
	[super dealloc];
}

- (NSString *)key {
	long long code = 0;
	code = self.url == nil ? 0 : abs([self.url javaHash]);
	code = code * 29 + (self.title == nil ? 0 : abs([self.title javaHash]));
	code = code * 29 + (self.pubDateObject == nil ? 0 : [self.pubDateObject timeIntervalSince1970] * 1000L);
	return [NSString stringWithFormat:@"%qx", code];
}

+ (NSDate *)dateFromString:(NSString *)string {
	NSDate *date = nil;
	
	if (string == nil) return nil;
	
	NSRange sixLastChars = NSMakeRange([string length] - 6, 6);
	if ([string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"-+"] options:NSLiteralSearch range:sixLastChars].location != NSNotFound &&
		[string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@":"]  options:NSLiteralSearch range:sixLastChars].location != NSNotFound) {
		if (![[string substringWithRange:NSMakeRange([string length] - 9, 3)] caseInsensitiveCompare:@"gmt"] == NSOrderedSame) {
			NSMutableString *mdate = [NSMutableString stringWithString:string];
			[mdate replaceOccurrencesOfString:@":" withString:@"" options:NSLiteralSearch range:sixLastChars];
			string = mdate;
		}
	}
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	
	NSString **format = DateFormats;
	while (*format && date == nil) {
		formatter.dateFormat = *format;
		date = [formatter dateFromString:string];
		if ([date timeIntervalSince1970] == 0) date = nil;
		format++;
	}
	
	[formatter release];
	
	return date;
}

@end
