//
//  MPLSSession.m
//  MPSsh
//
//  Created by Mauro Piccini on 9/16/12.
//
//

#import "MPLSSession.h"

NSString *ppwwdd;
static void kbd_callback(const char *name, int name_len,
                         const char *instruction, int instruction_len,
                         int num_prompts,
                         const LIBSSH2_USERAUTH_KBDINT_PROMPT *prompts,
                         LIBSSH2_USERAUTH_KBDINT_RESPONSE *responses,
                         void **abstract) {
    (void)name;
    (void)name_len;
    (void)instruction;
    (void)instruction_len;
    if (num_prompts == 1) {
        responses[0].text = strdup([ppwwdd UTF8String]);
        responses[0].length = strlen([ppwwdd UTF8String]);
        NSLog(@"Using pwd [%s]", [ppwwdd UTF8String]);
    }
    (void)prompts;
    (void)abstract;
} /* kbd_callback */


@interface MPLSSession ()

@property(nonatomic, strong) NSString *userauthlist;

@end

@implementation MPLSSession

LIBSSH2_SESSION *session;

- (id)init {
    self = [super init];
    if (self) {
        session = libssh2_session_init();
        self.userauthlist = nil;
    }
    return self;
}

-(NSString *)userauthListWithUser:(NSString *)user {
    if(!self.userauthlist) {
        char *ual = libssh2_userauth_list(session, [user UTF8String], [user length]);
        self.userauthlist = @(ual);
    }
    return self.userauthlist;
}

-(void)trace {
    libssh2_trace((session), LIBSSH2_TRACE_CONN |  LIBSSH2_TRACE_SOCKET | LIBSSH2_TRACE_ERROR | LIBSSH2_TRACE_KEX | LIBSSH2_TRACE_AUTH | LIBSSH2_TRACE_PUBLICKEY);
}

-(NSInteger) startupWithSock:(NSInteger)pSock {
    return libssh2_session_startup(session, pSock);
}

-(NSString *) hostkeyHash:(NSInteger) type {
    const char *ret = libssh2_hostkey_hash(session, type);
    
    NSMutableString *fingerprint = [[NSMutableString alloc] init];
    for(int i = 0; i < 20; i++) {
		[fingerprint appendFormat:@"%02X", (unsigned char)ret[i]];
		if(i<19) {
			[fingerprint appendString:@":"];
		}
    }
    return fingerprint;
}


-(NSString *)lastError {
    char *err_msg;
    libssh2_session_last_error(session, &err_msg, NULL, 0);
    return @(err_msg);
}

-(void) disconnectWithMessage:(NSString *)msg {
    libssh2_session_disconnect(session, [msg UTF8String]);
}
-(NSInteger) userauthPublickeyFromfileWithUser:(NSString *)user pub:(NSString *)rsaPub rsa:(NSString *)rsa passphrase:(NSString *)passphrase {
    
    return libssh2_userauth_publickey_fromfile(session, [user UTF8String], nil, [rsa UTF8String], [passphrase UTF8String]);
}

-(NSInteger) userauthPasswordWithUser:(NSString *)user password:(NSString *)password {
    return libssh2_userauth_password(session, [user UTF8String], [password UTF8String]);
}

-(NSInteger) userauthKeyboardInteractiveWithUser:(NSString *)user password:(NSString *)password {
    ppwwdd = password;
    NSInteger ret = libssh2_userauth_keyboard_interactive(session, [user UTF8String], &kbd_callback);
    ppwwdd = nil;
    return ret;
}


#pragma mark - authentication

-(BOOL) allowPublickKeyAuthentication {
    return [self.userauthlist rangeOfString:@"publickey"].length > 0;
}

-(BOOL) allowPasswordAuthentication {
    return [self.userauthlist rangeOfString:@"password"].length > 0;
}

-(BOOL) allowKeyboardInteractiveAuthentication {
    return [self.userauthlist rangeOfString:@"keyboard-interactive"].length > 0;
}

-(void) setBlocking:(BOOL)b {
    libssh2_session_set_blocking(session, b?1:0);
}

- (MPLSChannel *) channelOpenSession {
    LIBSSH2_CHANNEL *c = libssh2_channel_open_session(session);
    MPLSChannel *ret = [[MPLSChannel alloc] initWithChannel:c];
    return ret;
}

#pragma mark - sftp

-(LIBSSH2_SFTP *) sftpInit {
    return libssh2_sftp_init(session);
}


@end
