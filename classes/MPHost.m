//
//  LVHost.m
//  iLogViewer
//
//  Created by Mauro Piccini on 9/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


// MIT license
// Remember to add CFNetwork.framework to your project using Add=>Existing Frameworks.

#import "MPHost.h"

#ifdef COCOASSH_IOS
	#import <CFNetwork/CFNetwork.h>
#else
	#import <CoreServices/CoreServices.h>
#endif

#import <netinet/in.h>
#import <netdb.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/ethernet.h>
#import <net/if_dl.h>

@implementation MPHost

+ (NSString *)addressForHostname:(NSString *)hostname {
	NSArray *addresses = [MPHost addressesForHostname:hostname];
	if ([addresses count] > 0)
		return [addresses objectAtIndex:0];
	else
		return nil;
}

+ (NSArray *)addressesForHostname:(NSString *)hostname {
	// Get the addresses for the given hostname.
	CFHostRef hostRef = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)hostname);
	NSLog(@"created host");
	BOOL isSuccess = CFHostStartInfoResolution(hostRef, kCFHostAddresses, nil);
	NSMutableArray *addresses = nil;
	if (isSuccess) {
		NSLog(@"resolution ok");
		CFArrayRef addressesRef = CFHostGetAddressing(hostRef, nil);
		if (addressesRef != nil) {	
			NSLog(@"host addressing ok");
			// Convert these addresses into strings.
			char ipAddress[INET6_ADDRSTRLEN];
			addresses = [NSMutableArray array];
			NSLog(@"addresses is %@", addresses);
			CFIndex numAddresses = CFArrayGetCount(addressesRef);
			NSLog(@"found %ld addresses", numAddresses);
			for (CFIndex currentIndex = 0; currentIndex < numAddresses; currentIndex++) {
				NSLog(@"calc address number %ld", currentIndex);
				struct sockaddr *address = (struct sockaddr *)CFDataGetBytePtr(CFArrayGetValueAtIndex(addressesRef, currentIndex));
				if (address != nil) {
					NSLog(@"address is valid");
					getnameinfo(address, address->sa_len, ipAddress, INET6_ADDRSTRLEN, nil, 0, NI_NUMERICHOST);
					if (ipAddress != nil) {
						NSLog(@"ipAddress is valid");						
						NSString *iii = @(ipAddress);
						NSLog(@"ipAddress is %@", iii);						
						[addresses addObject:iii];
					} else {
						NSLog(@"ipAddress is nil");
						break;
					}

				} else {
					NSLog(@"address is nil");
					break;
				}

			}
		} else {
			NSLog(@"host addressing failed");
		}
	}else {
		NSLog(@"resolution failed");
	}
	NSLog(@"releasing hostref");
	CFRelease(hostRef);
	NSLog(@"release hostref ok");
	NSLog(@"returning %@", addresses);
	return addresses;
}

+ (NSString *)hostnameForAddress:(NSString *)address {
	NSArray *hostnames = [MPHost hostnamesForAddress:address];
	if ([hostnames count] > 0)
		return [hostnames objectAtIndex:0];
	else
		return nil;
}

+ (NSArray *)hostnamesForAddress:(NSString *)address {
	// Get the host reference for the given address.
    struct addrinfo      hints;
    struct addrinfo      *result = NULL;
	memset(&hints, 0, sizeof(hints));
	hints.ai_flags    = AI_NUMERICHOST;
	hints.ai_family   = PF_UNSPEC;
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_protocol = 0;
	int errorStatus = getaddrinfo([address cStringUsingEncoding:NSASCIIStringEncoding], NULL, &hints, &result);
	if (errorStatus != 0) return nil;
	CFDataRef addressRef = CFDataCreate(NULL, (UInt8 *)result->ai_addr, result->ai_addrlen);
	if (addressRef == nil) return nil;
	freeaddrinfo(result);
	CFHostRef hostRef = CFHostCreateWithAddress(kCFAllocatorDefault, addressRef);
	if (hostRef == nil) {
		CFRelease(addressRef);
		return nil;
	}
	CFRelease(addressRef);
	BOOL isSuccess = CFHostStartInfoResolution(hostRef, kCFHostNames, NULL);
	if (!isSuccess) {
		CFRelease(hostRef);
		return nil;
	}
	
	// Get the hostnames for the host reference.
	CFArrayRef hostnamesRef = CFHostGetNames(hostRef, NULL);
	NSMutableArray *hostnames = [NSMutableArray array];
	for (int currentIndex = 0; currentIndex < [(__bridge NSArray *)hostnamesRef count]; currentIndex++) {
		[hostnames addObject:[(__bridge NSArray *)hostnamesRef objectAtIndex:currentIndex]];
	}
	
	CFRelease(hostRef);
	return hostnames;
}

+ (NSArray *)ipAddresses {
	NSMutableArray *addresses = [NSMutableArray array];
	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *currentAddress = NULL;
	
	int success = getifaddrs(&interfaces);
	if (success == 0) {
		currentAddress = interfaces;
		while(currentAddress != NULL) {
			if(currentAddress->ifa_addr->sa_family == AF_INET) {
				NSString *address = @(inet_ntoa(((struct sockaddr_in *)currentAddress->ifa_addr)->sin_addr));
				if (![address isEqual:@"127.0.0.1"]) {
					NSLog(@"%@ ip: %@", @(currentAddress->ifa_name), address);
					[addresses addObject:address];
				}
			}
			currentAddress = currentAddress->ifa_next;
		}
	}
	freeifaddrs(interfaces);
	return addresses;
}

+ (NSArray *)ethernetAddresses {
	NSMutableArray *addresses = [NSMutableArray array];
	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *currentAddress = NULL;
	int success = getifaddrs(&interfaces);
	if (success == 0) {
		currentAddress = interfaces;
		while(currentAddress != NULL) {
			if(currentAddress->ifa_addr->sa_family == AF_LINK) {
				NSString *address = @(ether_ntoa((const struct ether_addr *)LLADDR((struct sockaddr_dl *)currentAddress->ifa_addr)));
				
				// ether_ntoa doesn't format the ethernet address with padding.
				char paddedAddress[80];
				int a,b,c,d,e,f;
				sscanf([address UTF8String], "%x:%x:%x:%x:%x:%x", &a, &b, &c, &d, &e, &f);
				sprintf(paddedAddress, "%02X:%02X:%02X:%02X:%02X:%02X",a,b,c,d,e,f);
				address = @(paddedAddress);
				
				if (![address isEqual:@"00:00:00:00:00:00"] && ![address isEqual:@"00:00:00:00:00:FF"]) {
					NSLog(@"%@ mac: %@", @(currentAddress->ifa_name), address);
					[addresses addObject:address];
				}
			}
			currentAddress = currentAddress->ifa_next;
		}
	}
	freeifaddrs(interfaces);
	return addresses;
}

@end
