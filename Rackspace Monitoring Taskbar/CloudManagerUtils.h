//
//  CloudManagerUtils.h
//  cloudmanager3
//
//  Created by Kevin Minnick on 11/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CloudManagerUtils : NSObject {

}

+(void) CMLog: (NSString*) format, ...;

+(void) showAlertWindow: (NSString*) errorMessage window: (NSWindow*) theWindow;
+(void) showApiError: (NSWindow*) theWindow;

@end
