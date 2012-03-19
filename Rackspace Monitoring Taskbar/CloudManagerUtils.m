//
//  CloudManagerUtils.m
//  cloudmanager3
//
//  Created by Kevin Minnick on 11/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CloudManagerUtils.h"
#import "RegexKitLite.h"
#import "constants.h"

@implementation CloudManagerUtils

//custom logging function that removes sensitive security info
+(void) CMLog: (NSString*) format, ... {
	
	if(DEBUG_LEVEL == NO_LOGGING)
		return;

	NSString *formatStr;
	va_list args;
	va_start(args,format);
	formatStr = [[NSString alloc] initWithFormat:format arguments: args];
	va_end(args);
	
	formatStr = [formatStr stringByReplacingOccurrencesOfRegex:@"apiKey=\".*?\"" withString:@"apiKey=\"XXXXXXXX\""];
	formatStr = [formatStr stringByReplacingOccurrencesOfRegex:@"<token\\s*id=\".*?\"" withString:@"token id=\"XXXXXXXX\""];
	formatStr = [formatStr stringByReplacingOccurrencesOfRegex:@"\"X-Auth-Token\"\\s*=\\s*\".*?\"" withString:@"\"X-Auth-Token\" = \"XXXXXXXX\""];
	formatStr = [formatStr stringByReplacingOccurrencesOfRegex:@"password\\s*=\\s*\".*?\"" withString:@"password=\"XXXXXXXX\""];
	
	NSLog(@"%@", formatStr);
			
}


+(void) showAlertWindow: (NSString*) errorMessage window: (NSWindow*) theWindow {
	
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];								
	[alert addButtonWithTitle:@"OK"];													
	[alert setMessageText:errorMessage];						
	[alert setAlertStyle:NSWarningAlertStyle];											
	[alert beginSheetModalForWindow:theWindow										
					  modalDelegate:self												
					 didEndSelector:nil													
						contextInfo:nil];
	
}

//macro for show api error
+(void) showApiError: (NSWindow*) theWindow {

	NSAlert *alert = [[[NSAlert alloc] init] autorelease];								
	[alert addButtonWithTitle:@"OK"];													
	[alert setMessageText:@"There was an error accessing the API"];						
	[alert setInformativeText:@"For more information, please check the console."];		
	[alert setAlertStyle:NSWarningAlertStyle];											
	[alert beginSheetModalForWindow:theWindow									
					  modalDelegate:self												
					 didEndSelector:nil													
						contextInfo:nil];												

}


@end
