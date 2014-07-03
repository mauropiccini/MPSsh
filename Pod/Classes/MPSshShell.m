//
//  LVShellSession.m
//  iLogViewer
//
//  Created by Mauro Piccini on 9/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MPSshShell.h"
#import "MPConnectionParams.h"


@interface MPSshShell() 

@property (nonatomic) BOOL customprompt;
@property (nonatomic) BOOL stopCmd;
@property (nonatomic, strong) MPLSChannel *channel;
@property (nonatomic) MPShellStatus status;
@property (nonatomic, strong) NSMutableArray *cmdResult;
@property (nonatomic) NSInteger cmdCounter;

@end

@implementation MPSshShell

- (id) initWithChannel:(MPLSChannel *)ch {
	self = [super init];
	if (self != nil) {
		self.customprompt = FALSE;
		self.stopCmd = FALSE;
        self.channel = ch;
        
            //libssh2_channel_setenv(self.channel, "FOO", "bar");
        int rc = [self.channel requestPty];
        if (rc<0) {
            NSLog(@"Failed requesting pty : %@\n", [self.session lastError]);
            if (self.channel) {
                [self.channel free];
                self.channel = NULL;
            }
            return nil;
        }
        
        /* Open a SHELL on that pty */
        if ([self.channel shell]) {
            NSLog(@"Unable to request shell on allocated pty\n");
            [self shutdown];
        }
        
        self.status = MPShellStatusIdle;
        
        [NSThread detachNewThreadSelector:@selector(receiver) toTarget:self withObject:nil];
        NSString *promptCommand = [NSString stringWithFormat:@"if [ $(which $SHELL) == '/bin/bash' ]; then export PS1='%@\n'; fi", LOGSPROMPT];
        [self execCommand:promptCommand];
        NSLog(@"connected = TRUE");
        
	}
	return self;
}

/*
	TODO : Gestire il caso di una righa più lunga del buffer!!!
 */
-(void) receiver {
	// deve essere un numero abbastanza grande da garantire almeno un a capo 
	char buffer[1024];
	int rc1 = 0;
	self.stopCmd = FALSE;
	NSString *res = nil;
	do {
        @autoreleasepool {
            // arrivo fino a buffer size -1 perchè poi ci metto lo 0 di fine stringa
            rc1 = [self.channel read:buffer]; //libssh2_channel_read( self.channel, buffer, 1023 );//sizeof(buffer)-1 );
            if ( rc1 > 0 ) {
                buffer[rc1]=0;
                
                DebugLog(@"received %d bytes buffer [%s]",rc1, buffer);
                
                
                char *nextstart = buffer;
                BOOL aChar = FALSE;

                for (int ii=0; ii<rc1; ii++) {
                    if (buffer[ii] == '\n' || buffer[ii] == '\r') {
                        DebugLog(@"newline found at %d", ii);
                        buffer[ii] = 0;
                        
                        if(aChar) {
                            aChar = FALSE;

                            /*
                             String sended to lib user. 
                             do not autorelease
                             */
                            
                            NSString *s = [NSString stringWithFormat:@"%@%s", res==nil?@"":res, nextstart];
                            res = nil;

                            [self dataReceived:s];
                        }

                        DebugLog(@"setting next start to index %d", (ii+1));
                        nextstart = &buffer[ii+1];

                    } else {
                        aChar = TRUE;
                    }

                }
                
                res = @(nextstart);
            } else {
                if ( self.status == MPShellStatusOnlineCommand ) {
                    [NSThread sleepForTimeInterval:0.2];                
                } else {
                    [NSThread sleepForTimeInterval:1];
                }

                if(rc1 == LIBSSH2_ERROR_EAGAIN) {
                    rc1 = 0;
                } else {
                    NSString *msg = [self.session lastError];
                    NSLog(@"error : %@", msg);
                }
                
            }
            
            [NSThread sleepForTimeInterval:0.01];
        }
	} while (rc1>=0 && !self.stopCmd);
	NSLog(@"quit receiver");

}

/*
	Test for command line echoed
 */
-(void)dataReceived:(NSString *)data {
	DebugLog(@"<- [%s]", [data UTF8String]);
	switch (self.status) {
		case MPShellStatusCommand:
			
			if([data isEqualToString:LOGSPROMPT]) {
				DebugLog(@"prompt received!");
				self.status = MPShellStatusCommandComplete;
				
			} else {
				[self.cmdResult addObject:data];
			}
			
			break;
		case MPShellStatusOnlineCommand:
            self.cmdCounter++;
            if(!self.delegate) {
                NSLog(@"here");
            } else {
                NSLog(@"here 2");
            }
			[self.delegate shellSession:self dataReceived:data counter:self.cmdCounter];
		default:
			break;
	}
}

-(void) execLongCommand:(NSString *)cmd {
	if([cmd characterAtIndex:[cmd length]-1] != '\n') {
		cmd = [cmd stringByAppendingString:@"\n"];
	}
	
	NSLog(@"execLongCommand [%@]", [cmd stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"]);
	
        //NSLog(@"writing to channel [%@]", cmd);
    [self.channel write:cmd];
	self.status = MPShellStatusOnlineCommand;
    self.cmdCounter = 0;
}

-(void) stopLongCommand {
	NSLog(@"stopLongCommand");
	[self sendCtrlC];
	self.status = MPShellStatusIdle;
}
	
-(NSArray *) execCommand:(NSString *)cmd {
	if([cmd characterAtIndex:[cmd length]-1] != '\n') {
		cmd = [cmd stringByAppendingString:@"\n"];
	}
	   	
	self.cmdResult = [NSMutableArray arrayWithCapacity:2];
	self.status = MPShellStatusCommand;
	
	NSLog(@"-> %@", cmd);
    [self.channel write:cmd];
	
	int counter = 0;
	while (self.status==MPShellStatusCommand && counter<100) {
		[NSThread sleepForTimeInterval:0.1];
		counter++;
	}
	
	NSLog(@"Response is [%@]", self.cmdResult);
	return self.cmdResult;
}


-(void) sendCtrlC {
    [self.channel ctrlC];
}

-(NSString *) readBuffer {
	NSString *ret = @"";
	char buffer[0x4000];
	int rc1 = 0;
	do {
		[NSThread sleepForTimeInterval:0.1];
		rc1 = [self.channel read:buffer];
		if(rc1>0) {
			buffer[rc1]=0;
			NSString *line = @(buffer);
			ret = [ret stringByAppendingString:line];
		}

	} while (rc1>0);
	
	return ret;	
}

-(void) shutdown {
    self.stopCmd = YES;
	if (self.channel) {
        [self.channel shutdown];
        self.channel = NULL;
    }
}	

@end
