//
//  NetworkUtils.m
//  cloudmanager3
//
//  Created by Kevin Minnick on 10/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "constants.h"
#import "NetworkUtils.h"
#import <SystemConfiguration/SCNetworkConfiguration.h>
#import <netinet/in.h>
#import "CloudManagerUtils.h"

@implementation NetworkUtils

+(BOOL) connectedToNetwork {
	
	struct sockaddr_in zeroAddr;
	bzero(&zeroAddr, sizeof(zeroAddr));
	zeroAddr.sin_len = sizeof(zeroAddr);
	zeroAddr.sin_family = AF_INET;
	
	SCNetworkConnectionFlags flags;
	SCNetworkReachabilityRef target = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *) &zeroAddr);
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(target, &flags);
	CFRelease(target);
	
	if (!didRetrieveFlags)
	{
		return NO;
	}
	
	BOOL isReachable = flags & kSCNetworkFlagsReachable;
	BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	
	if (isReachable && !needsConnection)
		return YES;
	
	[CloudManagerUtils CMLog:@"Not connected to a network."];
	
	return NO;	
	
}

+(ASIHTTPRequest *) getConnection:(NSString*) urlString 
					withAuthToken: (AuthToken*) authToken
                     withEndPoint: (NSString*) endPoint {
	
	if(!endPoint) {
		[CloudManagerUtils CMLog:@"Invalid server url, probably bad auth"];
		return nil;
	}
	
	if(!authToken) {
		authToken = [[AuthToken alloc] init];
	}	
	
	if(!authToken.token)
		[authToken authenticate];
	
	if(!authToken.token) {
		[CloudManagerUtils CMLog:@"Unable to get auth token"];
		return nil;		
	}
	
	NSString *listUrl = [NSString stringWithFormat:@"%@%@", endPoint, urlString];
	
	[CloudManagerUtils CMLog:@"Url: %s", [listUrl UTF8String]];
	
	NSURL *url = [NSURL URLWithString: listUrl];	
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	
	[request addRequestHeader:@"X-Auth-Token" value: authToken.token];
	//[request addRequestHeader:@"X-Auth-Project-Id" value: authToken.authProjectId];
	[request addRequestHeader:@"Content-Type" value: CONTENT_TYPE_HEADER];
	[request addRequestHeader:@"Accept" value: ACCEPT_HEADER];
	[request addRequestHeader:@"User-Agent" value: USER_AGENT];
	
	[CloudManagerUtils CMLog:@"Request Headers: %@", [request requestHeaders]];
	
	return request;
	
}

+(NSString *) urlEncoded: (NSString*) str {
	CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(
																	NULL,
																	(CFStringRef)str,
																	NULL,
																	(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
																	kCFStringEncodingUTF8 );
    return [(NSString *)urlString autorelease];
}

@end
