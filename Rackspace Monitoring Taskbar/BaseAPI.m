//
//  BaseAPI.m
//  cloudmanager3
//
//  Created by Kevin Minnick on 12/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseAPI.h"
#import "CloudManagerUtils.h"

@implementation BaseAPI

-(id) init {
	self = [super init];
	
	if(self) {
		authToken = [[AuthToken alloc] init];	
	}
	
	return self;
}

-(void) invalidateAuthtoken {
	
	if(authToken)
		[authToken release];
	
	authToken = nil;
}

-(void) requestDone:(ASIHTTPRequest *) request
{
	[CloudManagerUtils CMLog:@"Response Headers: %@", [request responseHeaders]];
		
	// Use when fetching binary data
	NSData *responseData = [request responseData];
	NSString *strData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
		
	[CloudManagerUtils CMLog:@"Data: %s", [strData UTF8String]]; 
}

-(void) requestFailed:(ASIHTTPRequest *) request
{
	NSError *error = [request error];
	if (error) {
		[CloudManagerUtils CMLog:@"Request %@", [request responseString]];
		[CloudManagerUtils CMLog:@"Error %@", error];
	}	
}


@end
