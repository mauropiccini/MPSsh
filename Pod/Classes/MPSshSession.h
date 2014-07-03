//
//  LVSession.h
//  CocoaSsh
//
//  Created by Mauro Piccini on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "libssh2_config.h"
#include <libssh2.h>
#include <libssh2_sftp.h>

#ifdef HAVE_WINDOWS_H
#include <windows.h>
#endif
#ifdef HAVE_WINSOCK2_H
#include <winsock2.h>
#endif
#ifdef HAVE_SYS_SOCKET_H
#include <sys/socket.h>
#endif
#ifdef HAVE_NETINET_IN_H
#include <netinet/in.h>
#endif
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif
#ifdef HAVE_ARPA_INET_H
#include <arpa/inet.h>
#endif

#include <sys/types.h>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <ctype.h>

#import "MPConnectionParams.h"

#define ERROR_AUTH_FAILED 101

typedef enum {
    MPSshSessionConnected,
    MPSshSessionEstablished,
    MPSshSessionAuthenticated,
    MPSshSessionInitialized,
    MPSshSessionOpened,
} MPSshSessionState;


@class MPSshSession;
@class MPSshShell;
@class MPSftpSession;

@protocol MPSshSessionDelegate<NSObject>

-(BOOL) shellSession:(MPSshSession *)shell fingerprint:(NSString *)fingerprint;
-(NSString *) shellRequestPassword:(MPSshSession *)shell;
-(void) shellRequestPassphrase:(MPSshSession *)shell;

@optional
- (void) shellSession:(MPSshSession *)shell didChangeState:(MPSshSessionState)state;
    //- (void) shellSession:(MPSshSession *)shell dataReceived:(NSString *)data counter:(NSInteger)counter;
@end



@interface MPSshSession : NSObject {


	int sock;

}

@property(nonatomic) BOOL connected;
@property(nonatomic, strong) id<MPSshSessionDelegate> delegate;

+(BOOL) libssh_init:(NSError **)error;
+(BOOL) libssh_exit:(NSError **)error;

- (BOOL)connectUsingParams:(MPConnectionParams *)params error:(NSError **)error;
- (void) shutdown;

- (MPSftpSession *)newSftpSession;
- (MPSshShell *)newSshShellWithError:(NSError **)error;

- (NSString *) lastError;

@end
