//
//  NetworkUtils.h
//  cloudmanager3
//
//  Created by Kevin Minnick on 10/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ASIHTTPRequest.h"
#import "AuthToken.h"

@interface NetworkUtils : NSObject {

}

+(BOOL) connectedToNetwork;

+(ASIHTTPRequest *) getConnection:(NSString*) urlString 
					withAuthToken: (AuthToken*) authToken
					 withEndPoint: (NSString*) endPoint;

+(NSString *) urlEncoded: (NSString*) str;

@end
