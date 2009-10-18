//
//  NSString+JavaHashTests.m
//  BlogBridge
//
//  Created by Aleksey Gureiev on 10/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSString+JavaHashTests.h"

@implementation NSString_JavaHashTests

- (void)testJavaHash {
	STAssertEquals([@"test" javaHash], 3556498, @"Wrong result");
	STAssertEquals([@"tester tester tester tester tester" javaHash], -706533761, @"Wrong result");
}

@end
