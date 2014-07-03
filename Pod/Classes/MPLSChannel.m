//
//  MPLSChannel.m
//  MPSsh
//
//  Created by Mauro Piccini on 9/16/12.
//
//

#import "MPLSChannel.h"

@implementation MPLSChannel

BOOL blocked;
LIBSSH2_CHANNEL *channel;

- (id)initWithChannel:(LIBSSH2_CHANNEL *)c {
    self = [super init];
    if (self) {
        channel = c;
    }
    return self;
}

- (NSInteger) requestPty {
    return libssh2_channel_request_pty(channel, "vanilla");
}
- (NSInteger) shell {
    return libssh2_channel_shell(channel);
}
-(void)free {
    libssh2_channel_free(channel);
}

-(NSInteger)read:(char[])buffer {
    blocked = YES;
    NSInteger ret = libssh2_channel_read( channel, buffer, 1023 );
    blocked = NO;
    return ret;
}

- (NSInteger) write:(NSString *)cmd {
    return libssh2_channel_write(channel, [cmd UTF8String], [cmd length]);
}

-(void) ctrlC {
    NSLog(@"sending ctrl+C");
	char cmd[1];
	cmd[0]=3;
	libssh2_channel_write(channel, cmd, 1);
}

- (void)shutdown {
    libssh2_channel_close(channel);
    if(blocked) {
        do {
                //TODO wait while reading!??!
            [NSThread sleepForTimeInterval:0.1];
        } while( blocked);
    }
    libssh2_channel_wait_closed(channel);
    
    libssh2_channel_free(channel);

}
@end
