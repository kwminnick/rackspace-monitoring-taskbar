//
//  AuthToken.m
//  obj-c2
//
//  Created by Kevin Minnick on 8/9/11.
//  Copyright 2011 Kevin Minnick. All rights reserved.
//

#import "AuthToken.h"
#import "constants.h"
#import "ASIHTTPRequest.h"
#import "CloudManagerUtils.h"
#import "AGKeychain.h"

@implementation AuthToken

@synthesize authUrl, authUser, authKey, token, tenantId;

-(id) init {

	self = [super init];
	[self authenticate];	
	return self;
}

-(void) authenticate {
				
	//reset these
	[self setToken: nil];
	
    NSString *theAuthUrl = RACKSPACE_AUTH2_URL;
    NSString *theAuthUser;
    NSString *theAuthKey;
 
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if([prefs objectForKey:@"apiUser"]) {
        theAuthUser = [[NSString alloc] initWithString:[prefs objectForKey:@"apiUser"]];
        
        //get the key from keychain
        theAuthKey = [AGKeychain getPasswordFromKeychainItem:RAX_MON_TASKBAR
                                                          withItemKind:RAX_MON_TASKBAR_ACCOUNT 
                                                           forUsername:theAuthUser];
    }

	if(theAuthUrl == nil || theAuthKey == nil  || theAuthUser == nil)
		return;
		
	NSURL *url;
	
	[self setAuthUrl: theAuthUrl];
	
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", theAuthUrl, @"tokens"]];
	
	NSString *postData = @"";
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	
    NSString *passwordStr, *xmlns;
		
    passwordStr = [NSString stringWithFormat:
						   @"<apiKeyCredentials username=\"%@\" apiKey=\"%@\"/>",
						   theAuthUser, theAuthKey];
    xmlns = @"http://docs.rackspace.com/identity/api/ext/RAX-KSKEY/v1.0";
			
    postData = [NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
						"<auth xmlns:xsi=\"http://www.w3.org/2001/XML-Schema-instance\""
						" xmlns=\"%@\" >"
						" %@"
						"</auth>", xmlns, passwordStr];			

		
    [request appendPostData:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestMethod:@"POST"];	
	
	[request addRequestHeader:@"Accept" value:@"application/xml"];
	[request addRequestHeader:@"Content-Type" value:@"application/xml"];
	
	[CloudManagerUtils CMLog:@"Request URL: %@", url];
	[CloudManagerUtils CMLog:@"Request Headers: %@", [request requestHeaders]];
	[CloudManagerUtils CMLog:@"Post Body: %s", [postData UTF8String]];
	
	[request startSynchronous];
	NSError *error = [request error];
	if (error) {
		[CloudManagerUtils CMLog:@"Response %@", [request responseString]];
		[CloudManagerUtils CMLog:@"Error %@", error];
		return;
	}
	
	// Use when fetching binary data
	NSData *responseData = [request responseData];
	NSString *strData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];			
	[CloudManagerUtils CMLog:@"Response Headers: %@", [request responseHeaders]];
	[CloudManagerUtils CMLog:@"Data: %s", [strData UTF8String]];
	[strData release];
		
	//request returned, but check for 200
	int statusCode = [request responseStatusCode];
	if(statusCode == 200 || statusCode == 204 || statusCode == 203) {
			
        // Use when fetching binary data
        NSData *responseData = [request responseData];
								
        //parse the xml
        NSXMLDocument* doc = [[NSXMLDocument alloc] initWithData:responseData options:0 error:nil];
        NSXMLElement* root  = [doc rootElement];
		
        //handle namespaces
        NSString *prefix = @"";
        if([[root prefix] length] > 0)
            prefix = [NSString stringWithFormat:@"%@:", [root prefix]];
        
        NSString *tokenPath = [NSString stringWithFormat:@"//%@token", prefix]; 
        NSString *servicePath = [NSString stringWithFormat:@"//%@serviceCatalog/%@service", prefix, prefix];
        NSString *endPointPath = [NSString stringWithFormat:@"%@endpoint", prefix];
		
        NSArray* tokenArray = [root nodesForXPath:tokenPath error:nil];
        for(NSXMLElement* xmlElement in tokenArray) {
            //pull the values from the xml
            NSString *tokenId = [[xmlElement attributeForName:@"id"] stringValue];
            if(tokenId)
                [self setToken: [NSString stringWithString:tokenId]];
            break;
        }
                
        NSArray* serviceArray = [root nodesForXPath:servicePath error:nil];
		for(NSXMLElement* xmlElement2 in serviceArray) {
			NSString *serviceType = [[xmlElement2 attributeForName:@"type"] stringValue];
			if(serviceType) {
				if([serviceType isEqualToString:@"compute"]) {
					NSArray* endPointArray = [xmlElement2 nodesForXPath:endPointPath error:nil];
					for(NSXMLElement *endPoint in endPointArray) {
						NSString *theTenantId = [[endPoint attributeForName:@"tenantId"] stringValue];
                        tenantId = [[NSString alloc] initWithString:theTenantId];
						break;
					}
				}
			}
		}

	}
}

//this requires auth 2.0
+(NSString*) getAccountNumber: (NSString*) theAuthUrl
					withAuthKey: (NSString*) theAuthKey 
				   withAuthUser: (NSString*) theAuthUser
{
		
	if(theAuthUrl == nil || theAuthKey == nil  || theAuthUser == nil)
		return nil;
		
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", theAuthUrl, @"tokens"]];
		
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	
	NSString *passwordStr, *xmlns;				
	passwordStr = [NSString stringWithFormat:
						@"<apiKeyCredentials username=\"%@\" apiKey=\"%@\"/>",
						theAuthUser, theAuthKey];
	xmlns = @"http://docs.rackspace.com/identity/api/ext/RAX-KSKEY/v1.0";			
		
	NSString *postData = [NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
				"<auth xmlns:xsi=\"http://www.w3.org/2001/XML-Schema-instance\""
				" xmlns=\"%@\">"
				" %@"
				"</auth>", xmlns, passwordStr];
		
	[request appendPostData:[postData dataUsingEncoding:NSUTF8StringEncoding]];
	[request setRequestMethod:@"POST"];		
	[request addRequestHeader:@"Accept" value:@"application/xml"];
	[request addRequestHeader:@"Content-Type" value:@"application/xml"];
	
	[CloudManagerUtils CMLog:@"Request URL: %@", url];
	[CloudManagerUtils CMLog:@"Request Headers: %@", [request requestHeaders]];
	[CloudManagerUtils CMLog:@"Post Body: %s", [postData UTF8String]];
	
	[request startSynchronous];
	NSError *error = [request error];
	if (error) {
		[CloudManagerUtils CMLog:@"Response %@", [request responseString]];
		[CloudManagerUtils CMLog:@"Error %@", error];
		return nil;
	}
	
	// Use when fetching binary data
	NSData *responseData = [request responseData];
	NSString *strData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];			
	[CloudManagerUtils CMLog:@"Response Headers: %@", [request responseHeaders]];
	[CloudManagerUtils CMLog:@"Data: %s", [strData UTF8String]];
	[strData release];
	
	//request returned, but check for 200
	int statusCode = [request responseStatusCode];
	NSString *tenantId = nil;
	if(statusCode == 200 || statusCode == 204 || statusCode == 203) {
		
		// Use when fetching binary data
		NSData *responseData = [request responseData];
		
		//parse the xml
		NSXMLDocument* doc = [[NSXMLDocument alloc] initWithData:responseData options:0 error:nil];
		NSXMLElement* root  = [doc rootElement];
        
        //handle namespaces
        NSString *prefix = @"";
        if([[root prefix] length] > 0)
            prefix = [NSString stringWithFormat:@"%@:", [root prefix]];
        
        NSString *servicePath = [NSString stringWithFormat:@"//%@serviceCatalog/%@service", prefix, prefix];
        NSString *endPointPath = [NSString stringWithFormat:@"%@endpoint", prefix];
				
		NSArray* serviceArray = [root nodesForXPath:servicePath error:nil];
		for(NSXMLElement* xmlElement in serviceArray) {
			NSString *serviceType = [[xmlElement attributeForName:@"type"] stringValue];
			if(serviceType) {
				if([serviceType isEqualToString:@"compute"]) {
					NSArray* endPointArray = [xmlElement nodesForXPath:endPointPath error:nil];
					for(NSXMLElement *endPoint in endPointArray) {
						tenantId = [[endPoint attributeForName:@"tenantId"] stringValue];
						break;
					}
				}
			}
		}
	}
	
	return tenantId;
}


-(void) dealloc {
	
	[authUrl release];
	[authUser release];
	[authKey release];
	[token release];
	[tenantId release];
	[super dealloc];
	
}

@end
