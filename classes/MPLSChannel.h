//
//  MPLSChannel.h
//  MPSsh
//
//  Created by Mauro Piccini on 9/16/12.
//
//

#import <Foundation/Foundation.h>
#import <libssh2.h>

@interface MPLSChannel : NSObject

- (id)initWithChannel:(LIBSSH2_CHANNEL *)c;
- (NSInteger) requestPty;
- (NSInteger) shell;
- (void) free;
- (NSInteger) read:(char[])buffer;
- (NSInteger) write:(NSString *)cmd;
- (void) ctrlC;
- (void) shutdown;

@end
