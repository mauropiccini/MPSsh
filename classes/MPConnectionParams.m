//
//  LVConnectionParams.m
//  CocoaSsh
//
//  Created by Mauro Piccini on 8/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MPConnectionParams.h"

@implementation MPConnectionParams

@synthesize ip,port;
@synthesize user, password;
@synthesize rsa, rsaPub, passphrase;
@synthesize requestPassword, requestPassphrase;

- (id)init {
    self = [super init];
    if (self) {
        self.requestPassword = NO;
        self.requestPassphrase = NO;
    }
    return self;
}




@end
