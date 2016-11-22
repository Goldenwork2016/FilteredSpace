//
//  NetworkActive.m
//  BeatPort
//
//  Created by Eric Chapman on 1/21/10.
//

#import "NetworkActive.h"


@implementation NetworkActive
static NSInteger _networkConnections=0;
+ (void)networkActiveConnection:(BOOL)active {
	
	//-------------------------------------------------------------------------
	// If this is an active call, increment the counter
	//-------------------------------------------------------------------------
	if(active)
		_networkConnections++;
	//-------------------------------------------------------------------------
	// Else decrement the counter
	//-------------------------------------------------------------------------
	else
		_networkConnections--;
	
	//-------------------------------------------------------------------------
	// If there are active connections, enable the network indicator
	//-------------------------------------------------------------------------
	if(_networkConnections>0)
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	//-------------------------------------------------------------------------
	// If not, disable the counter
	//-------------------------------------------------------------------------
	else
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
