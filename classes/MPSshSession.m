//
//  LVSession.m
//  CocoaSsh
//
//  Created by Mauro Piccini on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MPSshSession.h"
#import "MPHost.h"
#import "MPSshShell.h"
#import "MPSftpSession.h"
#import "MPLSSession.h"


@interface MPSshSession ()

@property(nonatomic, strong) MPLSSession *session;
@end

@implementation MPSshSession

- (id)init {
    self = [super init];
    if (self) {
        self.connected = FALSE;
    }
    
    return self;
}




-(NSString *)lastError {
    return [self.session lastError];
}





#pragma mark - user authentication





#pragma mark - lib

+(void) fillError:(NSError **)error WithCode:(NSInteger)code andDescription:(NSString *)msg {
    NSLog(@"Error : %@\n", msg);
    if(error!=nil){
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"myDomain" code:code userInfo:errorDetail];
    }
}

#pragma mark -
#pragma mark static init and destroy

+(BOOL) libssh_init:(NSError **)error {
	NSLog(@"init");
	int rc = libssh2_init(0);
	if (rc) {
        [self fillError:error WithCode:100 andDescription:@"libssh2 initialization failed"];
        return FALSE;
    }
	return TRUE;
}

+(BOOL) libssh_exit:(NSError **)error {
	libssh2_exit();
	return YES;
}

#pragma mark -
#pragma mark Connection

/*
 - (LVLibsshConnectionResult)connectTo:(NSString *)ip
 withUser:(NSString *)user
 andPassword:(NSString *)password
 andPort:(NSInteger)port
 error:(NSError **)error {
 return [self connectTo:ip port:port user:user password:pwd idRsaPub:nil idRsa:nil error:error];
 }
 */

-(BOOL)createSocket:(NSString *)ip port:(NSInteger)port error:(NSError **)error {
    unsigned long hostaddr;
    struct sockaddr_in sin;
    sock = -1;
	
    NSLog(@"calculating host address from [%@]", ip);
    NSString *ipAdr = [MPHost addressForHostname:ip];
    NSLog(@"ip address is %@", ipAdr);
    if(ipAdr == nil) {
        [MPSshSession fillError:error WithCode:100 andDescription:@"unable to resolve address"];
        
        return FALSE;
    }
    hostaddr = inet_addr([ipAdr UTF8String]);
	
	
    sin.sin_family = AF_INET;
    sin.sin_port = htons(port);
    sin.sin_addr.s_addr = hostaddr;
    CFSocketRef c = CFSocketCreate(NULL, 0, SOCK_STREAM, IPPROTO_TCP, 0, NULL, NULL);
    CFDataRef d = CFDataCreate(NULL, (UInt8*)(&sin), sizeof(struct sockaddr_in));
    CFSocketError e = CFSocketConnectToAddress(c, d, 5);
    CFRelease(d);
	
    if( e==kCFSocketError ) {
        CFRelease(c);
        [MPSshSession fillError:error WithCode:100 andDescription:@"failed to connect"];
        return NO;
    }
    if( e==kCFSocketTimeout ) {
        CFRelease(c);
        [MPSshSession fillError:error WithCode:100 andDescription:@"connection timeout"];
        return NO;
    }
    
        //TODO: Gestire salvandolo il socket ref per eliminarlo alla chiusura di sock
        //    CFRelease(e);
    sock = CFSocketGetNative(c);
        // test
        //CFRetain(c);
    
    return TRUE;
}

-(BOOL) manageFingerprintWithError:(NSError **)error {
    
    /* At this point we havn't authenticated. The first thing to do is check
     * the hostkey's fingerprint against our known hosts Your app may have it
     * hard coded, may go to a file, may present it to the user, that's your
     * call
     */
    NSString *fingerprint = [self.session hostkeyHash:LIBSSH2_HOSTKEY_HASH_SHA1];
    NSLog(@"Fingerprint: %@", fingerprint);
	
	if([self.delegate respondsToSelector:@selector(shellSession:fingerprint:)]) {
		if(![self.delegate shellSession:self fingerprint:fingerprint]) {
            [MPSshSession fillError:error WithCode:100 andDescription:@"fingerprint not accepted"];
			[self shutdown];
			return FALSE;
		}
	}
    return TRUE;
	
}

-(BOOL) authenticateWithPublickKey:(MPConnectionParams *)params error:(NSError **)error {
    NSInteger rc = [self.session userauthPublickeyFromfileWithUser:params.user pub:params.rsaPub rsa:params.rsa passphrase:params.passphrase];
    if (rc) {
        NSString *msg = [self lastError];
        NSLog(@"error code is %d, mesg %@", rc, msg);
        [MPSshSession fillError:error WithCode:ERROR_AUTH_FAILED andDescription:@"Authentication by public key failed"];
        return FALSE;
    }
    NSLog(@"\tAuthentication by public key succeeded.\n");
    return TRUE;
}

-(BOOL) authenticateWithPassword:(MPConnectionParams *)params error:(NSError **)error {
    NSInteger rc = [self.session userauthPasswordWithUser:params.user password:params.password];
    if (rc) {
        NSString *msg = [self lastError];
        NSLog(@"error code is %d, mesg %@", rc, msg);
        [MPSshSession fillError:error WithCode:ERROR_AUTH_FAILED andDescription:@"Authentication by password failed"];
        return NO;
    }
    NSLog(@"\tAuthentication by password succeeded.\n");
    return YES;
}

-(BOOL) authenticateWithKeyboard:(MPConnectionParams *)params error:(NSError **)error {
    NSInteger rc = [self.session userauthKeyboardInteractiveWithUser:params.user password:params.password];
    if ( rc ) {
        NSString *msg = [self lastError];
        NSLog(@"error code is %d, mesg %@", rc, msg);
        [MPSshSession fillError:error WithCode:ERROR_AUTH_FAILED andDescription:@"Authentication by keyboard-interactive failed"];
        return NO;
    }
    NSLog(@"\tAuthentication by keyboard-interactive succeeded.\n");
    return YES;
}


-(BOOL) authenticateWithParams:(MPConnectionParams *)params error:(NSError **)error {
    
    [self.session userauthListWithUser:params.user];
    BOOL auth = FALSE;
    BOOL tryed = NO;
    
    if ( [self.session allowPublickKeyAuthentication] ) {
        tryed = YES;
        auth = [self authenticateWithPublickKey:params error:error];
        params.requestPassphrase = !auth;
        
    }
    
    if (!auth && [self.session allowPasswordAuthentication]) {
        tryed = YES;
        auth = [self authenticateWithPassword:params error:error];
        params.requestPassword = !auth;
        
    }
    
    if (!auth && [self.session allowKeyboardInteractiveAuthentication]) {
        tryed = YES;
        auth = [self authenticateWithKeyboard:params error:error];
        params.requestPassword = YES;
        
    }
    
    if(!tryed) {
        [MPSshSession fillError:error WithCode:ERROR_AUTH_FAILED andDescription:@"No supported authentication methods found"];
    }
    
    if(!auth) {
        [self shutdown];
        return NO;
    }
    
    return YES;
}

- (BOOL)connectUsingParams:(MPConnectionParams *)params error:(NSError **)error {
	
	if(params.user==nil) {
		NSLog(@"nil user on connect. Using empty string.");
		params.user = @"";
	}
    
	if(params.password==nil) {
		NSLog(@"nil password on connect. Using empty string.");
		params.password = @"";
	}
    
	if(params.rsa==nil) {
		NSLog(@"nil rsa on connect. Using empty string.");
		params.rsa = @"";
	}
    
	if(params.rsaPub==nil) {
		NSLog(@"nil rsaPub on connect. Using empty string.");
		params.rsaPub = @"";
	}
    
    if(params.port==0) {
        params.port = 22;
    }
	
	if(self.connected) {
		NSLog(@"already connected");
		return YES;
	}
    BOOL retry;
    do {
        retry = NO;
        
        if(![self createSocket:params.ip port:params.port error:error]) {
            return NO;
        }
        
        NSLog(@"connected");
        if([self.delegate respondsToSelector: @selector(shellSession:didChangeState:)]) {
            [self.delegate shellSession:self didChangeState:MPSshSessionConnected];
        }
        
        self.session = [[MPLSSession alloc] init];

        [self.session trace];
        
        if ([self.session startupWithSock:sock]) {
                //            NSString *msg = [NSString stringWithFormat:@"Failure establishing SSH session:%@", [self lastError]];
            NSString *msg = [NSString stringWithFormat:@"%@", [self lastError]];
            
            TFLog(msg);
            [MPSshSession fillError:error WithCode:100 andDescription:msg];
            return NO;
        }
        
        if([self.delegate respondsToSelector: @selector(shellSession:didChangeState:)]) {
            [self.delegate shellSession:self didChangeState:MPSshSessionEstablished];
        }
        
        if(![self manageFingerprintWithError:error]) {
            return NO;
        }
        
        BOOL auth = [self authenticateWithParams:params error:error];
        if(!auth) {
            if(params.requestPassword) {
                if([self.delegate respondsToSelector: @selector(shellRequestPassword:)]) {
                    NSString *pwd = [self.delegate shellRequestPassword:self];
                    if(pwd!=nil) {
                        [self shutdown];
                        params.password = pwd;
                        retry = YES;
                    }
                }
            }
            /*
             if(params.requestPassphrase) {
             if(self.delegate && [self.delegate respondsToSelector: @selector(shellRequestPassphrase:)]) {
             [delegate shellRequestPassphrase:self];
             }
             }
             */
            if(!retry) {
                return NO;
            }
        }
    } while (retry);
	
    if([self.delegate respondsToSelector: @selector(shellSession:didChangeState:)]) {
		[self.delegate shellSession:self didChangeState:MPSshSessionAuthenticated];
	}
    
    
	NSLog(@"connected = TRUE");
	self.connected = TRUE;
    [self.session setBlocking:YES];
	return YES;
}


-(void) shutdown {
    [self.session disconnectWithMessage:@"Normal Shutdown, Thank you for playing"];
    //libssh2_session_free(session);
	
	if ( sock!=-1 ) {
		close(sock);
	}
	NSLog(@"connected = FALSE");
	self.connected = FALSE;
}


#pragma mark - shell and sessions

-(MPSftpSession *)newSftpSession {
    LIBSSH2_SFTP *s = [self.session sftpInit];
    if (!s) {
        NSLog(@"Unable to open a sftp session : %@\n", [self lastError]);
        fprintf(stderr, "Unable to init SFTP session\n");
        return nil;
    }
    

    MPSftpSession *ret = [[MPSftpSession alloc] initWithSftpSession:s];
    return ret;    
}


-(MPSshShell *)newSshShellWithError:(NSError **)error {
    MPLSChannel *c = [self.session channelOpenSession];
    if (!c) {
            //libssh2_session_last_error(session,NULL,NULL,0) == LIBSSH2_ERROR_EAGAIN
        NSLog(@"Unable to open a session : %@\n", [self lastError]);
            //[self shutdown];
		if(error!=nil) {
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionaryWithObject:@"Unable to open a session" forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:@"myDomain" code:100 userInfo:errorDetail];
		}
		return nil;
    }

	if([self.delegate respondsToSelector:@selector(didOpenSshSession:)])
        [self.delegate shellSession:self didChangeState:MPSshSessionOpened];

    
    MPSshShell *ret = [[MPSshShell alloc] initWithChannel:c];
    ret.session = self;
    return ret;
}


@end
