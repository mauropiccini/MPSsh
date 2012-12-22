//
//  LVConnectionParams.h
//  CocoaSsh
//
//  Created by Mauro Piccini on 8/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPConnectionParams : NSObject


@property (nonatomic, strong) NSString *ip;
@property (nonatomic) NSInteger port;
@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *rsaPub;
@property (nonatomic, strong) NSString *rsa;
@property (nonatomic, strong) NSString *passphrase;

@property (nonatomic) BOOL requestPassword;
@property (nonatomic) BOOL requestPassphrase;

@end
