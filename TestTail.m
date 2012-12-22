//
//  TestTail.m
//  CocoaSsh
//
//  Created by Mauro Piccini on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TestTail.h"
#import <mach/mach.h>
#import <mach/mach_host.h>


@implementation TestTail

@synthesize delegate;

+(natural_t) get_free_memory {
	mach_port_t host_port;
	mach_msg_type_number_t host_size;
	vm_size_t pagesize;
	host_port = mach_host_self();
	host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
	host_page_size(host_port, &pagesize);
	vm_statistics_data_t vm_stat;
	if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
		NSLog(@"Failed to fetch vm statistics");
		return 0;
	}
	/* Stats in bytes */
	natural_t mem_free = vm_stat.free_count * pagesize;
	return mem_free;
}

-(void) startTest {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	_session = [[MPSshShell alloc] init];
	_session.delegate = self;
	NSError *error;
	LVLibsshConnectionResult res = [_session connectTo:@"192.168.13.18" withUser:@"mauropiccini" andPassword:@"aneurysm" andPort:22 error:&error];
	switch (res) {
		case LVLibsshConnectionResultOk:
			NSLog(@"connect ok");
			break;
		case LVLibsshConnectionResultSuspended:
			NSLog(@"connect suspended");			
			break;
		case LVLibsshConnectionResultFailed:
			NSLog(@"connect failed");			
			break;
		default:
			break;
	}

	NSLog(@"inizio tail");	
	[_session execLongCommand:@"tail -n 200 -f /Users/mauropiccini/tmp/test.log"];
	tailstart = CACurrentMediaTime();
	count = 0;
	[NSThread sleepForTimeInterval:120];
	[_session sendCtrlC];
	[pool release];
}

-(BOOL) shellSession:(LVLibssh *)shell fingerprint:(NSString *)fingerprint {
	return YES;
}

-(void) shellSession:(LVLibssh *)shell dataReceived:(NSString *)data {
	if([data length]>2) {
		if([data characterAtIndex:0]!='>') {
			[self.delegate print:[NSString stringWithFormat:@"first character error in [%s]", [data UTF8String]]];
		}
		if([data characterAtIndex:[data length]-1]!='<') {
			[self.delegate print:[NSString stringWithFormat:@"last character error in [%s]", [data UTF8String]]];
		}
	}
	
	count++;
	if(count > 100) {
		count = 0;
		double t = CACurrentMediaTime();
		double d = t - tailstart;
		if(d==0) {
			[self.delegate print:@"rows per sec : inf"];
		} else {
			[self.delegate print:[NSString stringWithFormat:@"free mem : %.1fKb - rows per sec : %.2f", ([TestTail get_free_memory]/1024.0), 100.0/d]];
		}

		
		tailstart = t;
	}
	
}

@end
