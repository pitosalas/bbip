//
//  NSString+javaHash.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 10/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString(JavaHash)

/** Returns the hash calculated analogously to Java machine. */
- (NSInteger) javaHash;

@end
