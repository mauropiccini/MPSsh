//
//  MPLSSession.h
//  MPSsh
//
//  Created by Mauro Piccini on 9/16/12.
//
//

#import <Foundation/Foundation.h>
#include <libssh2.h>
#include <libssh2_sftp.h>
#import "MPLSChannel.h"

@interface MPLSSession : NSObject


- (id)init;

-(NSString *)userauthListWithUser:(NSString *)user;
-(NSInteger) startupWithSock:(NSInteger)pSock;
-(NSString *) hostkeyHash:(NSInteger) type;

-(NSString *)lastError;
-(void) disconnectWithMessage:(NSString *)msg;
-(NSInteger) userauthPublickeyFromfileWithUser:(NSString *)user pub:(NSString *)rsaPub rsa:(NSString *)rsa passphrase:(NSString *)passphrase;
-(NSInteger) userauthPasswordWithUser:(NSString *)user password:(NSString *)password;
-(NSInteger) userauthKeyboardInteractiveWithUser:(NSString *)user password:(NSString *)password;

-(BOOL) allowPublickKeyAuthentication;
-(BOOL) allowPasswordAuthentication;
-(BOOL) allowKeyboardInteractiveAuthentication;
-(void) setBlocking:(BOOL)b;
-(void)trace;

-(MPLSChannel *) channelOpenSession;
-(LIBSSH2_SFTP *) sftpInit;

@end
