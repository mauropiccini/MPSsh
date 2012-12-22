//
//  Tester.h
//  CocoaSsh
//
//  Created by Mauro Piccini on 12/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LVSFTPSession.h"
#import "MPSshShell.h"

@protocol TesterDelegate

	-(void) print:(NSString *)text;

@end


@interface Tester : NSObject <LVShellSessionDelegate> {

	id<TesterDelegate> _delegate;
	MPSshShell *_session;
}

@property(nonatomic, retain) id<TesterDelegate> delegate;

-(void) runAll;

@end
