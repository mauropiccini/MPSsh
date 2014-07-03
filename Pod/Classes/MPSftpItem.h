//
//  LVSftpItem.h
//  Logs
//
//  Created by Mauro Piccini on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


@interface MPSftpItem : NSObject {

	BOOL directory;
	NSString *name;
	NSInteger size;
}

@property (nonatomic) BOOL directory;
@property (nonatomic) NSInteger size;
@property (nonatomic, strong) NSString *name;

- (NSString *) sizeAsString;
- (BOOL) isLog;

@end
