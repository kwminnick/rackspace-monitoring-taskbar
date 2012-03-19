//
//  BaseAPI.h
//  cloudmanager3
//
//  Created by Kevin Minnick on 12/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AuthToken.h"
#import "ASIHTTPRequest.h"
#import "constants.h"

@interface BaseAPI : NSObject {
	AuthToken *authToken;
}

-(void) invalidateAuthtoken;

-(void) requestDone:(ASIHTTPRequest *) request;
-(void) requestFailed:(ASIHTTPRequest *) request;

@end
