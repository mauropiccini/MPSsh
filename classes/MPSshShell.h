//
//  LVShellSession.h
//  iLogViewer
//
//  Created by Mauro Piccini on 9/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MPSshSession.h"
#import "MPLSChannel.h"

#define LOGSPROMPT @"123logs123"

#ifdef DEBUG_COCOASSH
#define DebugLog(args...) NSLog(args);
#else
#define DebugLog(x...)
#endif

@class MPSshShell;

typedef enum {
    MPShellStatusIdle,
    MPShellStatusCommand,
    MPShellStatusCommandComplete,
	MPShellStatusOnlineCommand
} MPShellStatus;

@protocol MPSshShellSessionDelegate<NSObject>
- (void) shellSession:(MPSshShell *)shell dataReceived:(NSString *)data counter:(NSInteger)counter;
@end


@interface MPSshShell : NSObject {
}

@property (nonatomic, strong) id<MPSshShellSessionDelegate> delegate;
@property (nonatomic, weak) MPSshSession *session;


-(id) initWithChannel:(MPLSChannel *)ch;

-(void) shutdown;
-(NSString *) readBuffer;
-(NSArray *) execCommand:(NSString *)cmd;
-(void) execLongCommand:(NSString *)cmd;
-(void) sendCtrlC;
-(void) stopLongCommand;
//-(void) waitForWelcome;


-(void)dataReceived:(NSString *)data;

@end
