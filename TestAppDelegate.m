//
//  TestAppDelegate.m
//  CocoaSsh
//
//  Created by Mauro Piccini on 12/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TestAppDelegate.h"


@implementation TestAppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    NSError *error;
	if(![MPSshShell libssh_init:&error]) {
		NSLog(@"%@", error);
	}
	
    [self.window makeKeyAndVisible];
    return YES;
}



@end
