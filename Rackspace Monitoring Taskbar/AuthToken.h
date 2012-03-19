//
//  AuthToken.h
//  obj-c2
//
//  Created by Kevin Minnick on 8/9/11.
//  Copyright 2011 Kevin Minnick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthToken : NSObject {

	NSString *authUrl;
	NSString *authVersion;
	NSString *authUser;
	NSString *authKey;
	NSString *token;	
	NSString *tenantId;

}

@property (copy, nonatomic) NSString *authUrl, *authUser, *authKey, *token, *tenantId;

-(void) authenticate;

+(NSString*) getAccountNumber: (NSString*) theAuthUrl 
					withAuthKey: (NSString*) theAuthKey 
				 withAuthUser: (NSString*) theAuthUser;

@end
