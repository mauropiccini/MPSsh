//
//  LVSFTPSession.m
//  Logs
//
//  Created by Mauro Piccini on 10/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MPSftpSession.h"

@interface MPSftpSession ()

@property (nonatomic) 	LIBSSH2_SFTP *sftp_session;
@property (nonatomic) 	LIBSSH2_SFTP_HANDLE *sftp_handle;

@end


@implementation MPSftpSession

- (id)initWithSftpSession:(LIBSSH2_SFTP *)s {
    self = [super init];
    if (self) {
        self.sftp_session = s;
        
        /* Since we have not set non-blocking, tell libssh2 we are      */
        //[self.session setBlocking:TRUE];
        
        fprintf(stderr, "libssh2_sftp_opendir()!\n");
        
    }
    return self;
}

-(MPSftpItem *) file:(NSString *)path {
	MPSftpItem *ret = nil;
	
	int rc;
	
    /* Request a dir listing via SFTP */ 
    self.sftp_handle = libssh2_sftp_open(self.sftp_session, [path UTF8String], LIBSSH2_FXF_READ, 0);
	if (!self.sftp_handle) {
        fprintf(stderr, "Unable to open file with SFTP\n");
        return nil;
    }
    fprintf(stderr, "libssh2_sftp_opendir() is done, now receive listing!\n");
	
	LIBSSH2_SFTP_ATTRIBUTES attrs;
	rc = libssh2_sftp_stat(self.sftp_session, [path UTF8String], &attrs);
			
    if(rc == 0) {
		ret = [[MPSftpItem alloc] init];
		ret.name = [path lastPathComponent];				
			
		if(attrs.flags & LIBSSH2_SFTP_ATTR_PERMISSIONS) {			
			if(LIBSSH2_SFTP_S_ISDIR(attrs.permissions)) {
				ret.directory = YES;
			}
			if(LIBSSH2_SFTP_S_ISLNK(attrs.permissions)) {
				ret.directory = YES;
			}
		}
		
		if(attrs.flags & LIBSSH2_SFTP_ATTR_SIZE) {
			ret.size = attrs.filesize;
		}
		
	}			
		
	return ret;
	
}

- (NSMutableArray *) filesInDirectory:(NSString *)directory {
	int rc;
		
    self.sftp_handle = libssh2_sftp_opendir(self.sftp_session, [directory UTF8String]);
	
    if (!self.sftp_handle) {
        fprintf(stderr, "Unable to open dir with SFTP\n");
        return nil;
    }
    fprintf(stderr, "libssh2_sftp_opendir() is done, now receive listing!\n");
	
	NSMutableArray *ret = [[NSMutableArray alloc] init];
    do {
        char mem[512];
        char longentry[512];
        LIBSSH2_SFTP_ATTRIBUTES attrs;
		
        rc = libssh2_sftp_readdir_ex(self.sftp_handle, mem, sizeof(mem), longentry, sizeof(longentry), &attrs);
        if(rc > 0) {
            MPSftpItem *item = [[MPSftpItem alloc] init];
            item.name = @(mem);				
            
            if(attrs.flags & LIBSSH2_SFTP_ATTR_PERMISSIONS) {
                if(LIBSSH2_SFTP_S_ISDIR(attrs.permissions)) {
                    item.directory = YES;
                }
                if(LIBSSH2_SFTP_S_ISLNK(attrs.permissions)) {
                    item.directory = YES;
                }
            }
            
            item.size = attrs.filesize;
            NSLog(@"%@", item.name);
            
            if( ![item.name hasPrefix:@"."] ) {
                [ret addObject:item];
            }

        } else if(rc==LIBSSH2_ERROR_EAGAIN) {
            printf(".");

        } else {
            break;
		}
    } while (1);
	
	
	return ret;
	
}

- (void) dealloc {
	
	if(self.sftp_handle!=nil) {
		libssh2_sftp_closedir(self.sftp_handle);
		self.sftp_handle = nil;
	}
	
	if(self.sftp_session!=nil) {
		libssh2_sftp_shutdown(self.sftp_session);
		self.sftp_session = nil;
	}
}



@end
