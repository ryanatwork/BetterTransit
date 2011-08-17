//
//  NSString+Trim.m
//  BetterTransit
//
//  Created by Yaogang Lian on 10/18/10.
//  Copyright 2010 Happen Next. All rights reserved.
//

#import "NSString+Trim.h"


@implementation NSString (Trim)

- (NSString *)trim
{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
