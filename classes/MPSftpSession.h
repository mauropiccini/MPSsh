//
//  LVSFTPSession.h
//  Logs
//
//  Created by Mauro Piccini on 10/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MPSftpItem.h"
#import "MPSshSession.h"

@interface MPSftpSession : NSObject {

	
}


@property (nonatomic, strong) MPSshSession *session;

- (id)initWithSftpSession:(LIBSSH2_SFTP *)s;

- (MPSftpItem *) file:(NSString *)path;
- (NSMutableArray *) filesInDirectory:(NSString *)directory;

@end
