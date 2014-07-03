//
//  MPViewController.m
//  MPSsh
//
//  Created by Mauro Piccini on 06/30/2014.
//  Copyright (c) 2014 Mauro Piccini. All rights reserved.
//

#import "MPViewController.h"
#import "MPSsh/MPHost.h"

@interface MPViewController ()

@end

@implementation MPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSArray *s = [MPHost addressesForHostname:@"www.myti.it"];
    NSLog(@"%@", s);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
