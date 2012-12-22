//
//  TestTail.h
//  CocoaSsh
//
//  Created by Mauro Piccini on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "MPSshShell.h"

@protocol TestTailDelegate

-(void) print:(NSString *)text;

@end


@interface TestTail : NSObject <LVShellSessionDelegate> {

	MPSshShell *_session;

	double tailstart;
	long count;
	id<TestTailDelegate> _delegate;

}
@property(nonatomic, retain) id<TestTailDelegate> delegate;


-(void) startTest;

@end
