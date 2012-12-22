//
//  TestView.m
//  CocoaSsh
//
//  Created by Mauro Piccini on 12/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TestView.h"

@implementation TestView

@synthesize text = _text;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}

-(IBAction) btnTestPressed:(id)sender{
	self.text.text = @"";
	Tester *t = [[Tester alloc] init];
	t.delegate = self;
		
	[NSThread detachNewThreadSelector:@selector(runAll) toTarget:t withObject:nil];
	[t release];
}

-(IBAction) btnTest2Pressed:(id)sender{
	self.text.text = @"";
	TestTail *t = [[TestTail alloc] init];
	t.delegate = self;
	[NSThread detachNewThreadSelector:@selector(startTest) toTarget:t withObject:nil];
}

-(void) print:(NSString *)text {
	[self performSelectorOnMainThread:@selector(append:) withObject:text waitUntilDone:NO];
}

-(void) append:(NSString *)text {
	self.text.text = [NSString stringWithFormat:@"%s\n%s", [text UTF8String], [self.text.text UTF8String]];
	//self.text.text = [self.text.text stringByAppendingFormat:@"%s\n", [text UTF8String]];
}

-(void) didReceiveMemoryWarning {
	NSLog(@"mp memoria paurosa");
}


@end
