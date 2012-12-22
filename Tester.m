//
//  Tester.m
//  CocoaSsh
//
//  Created by Mauro Piccini on 12/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Tester.h"


@implementation Tester

@synthesize delegate = _delegate;

- (BOOL) shellSession:(LVLibssh *)shell fingerprint:(NSString *)fingerprint {
	[self.delegate print:[NSString stringWithFormat:@"fingerprint %s", [fingerprint UTF8String]]];
	return YES;
}

-(void) shellSession:(LVLibssh *)shell dataReceived:(NSString *)data {
	[self performSelectorOnMainThread:@selector(append:) withObject:data waitUntilDone:NO];
}

-(void)append:(NSString *)str {
	[self.delegate print:str];
}

-(void) setup {
	_session = [[MPSshShell alloc] init];
	_session.delegate = self;
	NSError *error;
	LVLibsshConnectionResult res = [_session connectTo:@"127.0.0.1" withUser:@"mauropiccini" andPassword:@"aneurysm" andPort:22 error:&error];
	switch (res) {
		case LVLibsshConnectionResultOk:
			[self.delegate print:@"connect ok"];			
			break;
		case LVLibsshConnectionResultSuspended:
			[self.delegate print:@"connect suspended"];			
			break;
		case LVLibsshConnectionResultFailed:
			[self.delegate print:@"connect failed"];			
			break;
		default:
			break;
	}
	[self.delegate print:@"testo"];	
}

-(void) test1 {
	
	[self.delegate print:@"executing -ll-"];
	for(NSString *str in [_session execCommand:@"ll"]) {
		[self.delegate print:str];
	}
}

-(void) test2 {
	[self.delegate print:@"inizio tail"];	
	[_session execLongCommand:@"tail -n 200 -f /Users/mauropiccini/tmp/test.log"];
	[NSThread sleepForTimeInterval:15];
	[self.delegate print:@"fine tail"];
}

-(void) tearDown {
	[_session shutdown];
	[_session release];
}



-(void) runAll {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	[self setup];
	//[self test1];
	[self test2];
	[self tearDown];
	[p release];
}
@end
