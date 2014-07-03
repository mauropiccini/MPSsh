//
//  LVSftpItem.m
//  Logs
//
//  Created by Mauro Piccini on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MPSftpItem.h"


@implementation MPSftpItem

@synthesize directory, name, size;

- (NSComparisonResult)compare:(MPSftpItem *)otherObject {
	if(otherObject.directory && !self.directory ){
		return  NSOrderedDescending;
	}
	if(!otherObject.directory && self.directory ){
		return  NSOrderedAscending;
	}
    return [self.name compare:otherObject.name options:NSCaseInsensitiveSearch];
}

- (BOOL) isLog {
    return [[self.name lowercaseString] hasSuffix:@".log"];
}


- (NSString *) sizeAsString {
	
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setUsesGroupingSeparator:YES];
	[nf setGroupingSeparator:@"."];
	[nf setGroupingSize:3];
	
	NSNumber *n = @(self.size);
	return [NSString stringWithFormat:@"%@ bytes", [nf stringFromNumber:n]];
}

-(void)dealloc {
    NSLog(@"here");
}
@end
