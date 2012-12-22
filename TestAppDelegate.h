//
//  TestAppDelegate.h
//  CocoaSsh
//
//  Created by Mauro Piccini on 12/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPSshShell.h"
#import "TestView.h"

@interface TestAppDelegate : NSObject<UIApplicationDelegate> {
    UIWindow *window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
