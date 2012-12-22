//
//  LVHost.h
//  iLogViewer
//
//  Created by Mauro Piccini on 9/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


@interface MPHost : NSObject {

}

+ (NSString *)addressForHostname:(NSString *)hostname;
+ (NSArray *)addressesForHostname:(NSString *)hostname;
+ (NSArray *)hostnamesForAddress:(NSString *)address;

@end
