//
//  Atom10Parser.h
//  BlogBridge
//
//  Created by Aleksey Gureiev on 8/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractParser.h"


@interface Atom10Parser : AbstractParser {
	NSDictionary *elementsToFields;
}

@end
