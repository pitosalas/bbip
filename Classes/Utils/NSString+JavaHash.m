//
//  NSString+javaHash.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 10/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSString+javaHash.h"


@implementation NSString(javaHash)

/** Returns the hash calculated analogously to Java machine. */
- (NSInteger) javaHash {
	int hash = 0;
	
	for (int i = 0; i < [self length]; i++) {
		unichar c = [self characterAtIndex:i];
		hash = 31 * hash + c;
	}
	
	return hash;
}

//+ (int)stringHashCode:(NSString *)string {
/*
 public int hashCode() {
 int h = hash;
 if (h == 0) {
 int off = offset;
 char val[] = value;
 int len = count;
 
 for (int i = 0; i < len; i++) {
 h = 31*h + val[off++];
 }
 hash = h;
 }
 return h;
 }
 */
//}

@end
