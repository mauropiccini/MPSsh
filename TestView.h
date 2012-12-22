//
//  TestView.h
//  CocoaSsh
//
//  Created by Mauro Piccini on 12/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tester.h"
#import "TestTail.h"

@interface TestView : UIViewController <TesterDelegate, TestTailDelegate> {

	 UITextView *_text;
}

@property (nonatomic, retain) IBOutlet UITextView *text;

-(IBAction) btnTestPressed:(id)sender;
-(IBAction) btnTest2Pressed:(id)sender;

@end
