//
//  MonMenulet.m
//  Rackspace Monitoring Taskbar
//
//  Created by Kevin Minnick on 3/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MonMenulet.h"
#import "AGKeychain.h"
#import "constants.h"
#import "Monitor.h"

@implementation MonMenulet

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) awakeFromNib {
    
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    
    [statusItem setHighlightMode:YES];
    [statusItem setTitle:[NSString stringWithString:@""]];
    [statusItem setEnabled:YES];
    [statusItem setToolTip:@"Rackspace Cloud Monitoring Status Checker"];
    
    [statusItem setAction:@selector(updateStatus:)];
    [statusItem setTarget:self];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"cloudmonitoring" ofType:@"tif"];
    menuIcon = [[NSImage alloc] initWithContentsOfFile:path];
    
    [statusItem setImage:menuIcon];
    
    [statusItem setMenu:theMenu];
    
    timerRefresh = 60.0;
    updateTimer = [[NSTimer scheduledTimerWithTimeInterval:(timerRefresh) 
                                                target:self
                                                  selector:@selector(updateStatus:) userInfo:nil
                                                   repeats:YES] retain];
    [updateTimer fire];
}

-(IBAction) updateStatus:(id)sender {
    
    if(!mApi)
        mApi = [[MonitoringAPI alloc] init];
    
    NSArray *overviews = [mApi getOverviews];
    
    for(MonOverview *mo in overviews) {
        NSArray *alarmStates = [mo getAlarmStates];
        for(MonAlarmState *mas in alarmStates) {
            //todo
        }
    }
    
    NSString *status = [NSString stringWithString:@""];
    [statusItem setTitle:[NSString stringWithString:status]];
     
}

-(IBAction) showMonitoringWindow:(id)sender {
    
    if(!monWindow)
        return;  //shouldn't happen
    
    [NSApp activateIgnoringOtherApps:YES];
    [monWindow makeKeyAndOrderFront:sender];
    
}

//preferences windows
-(IBAction) showPrefsWindow:(id)sender {
    if(!prefsWindow)
        return;  //shouldn't happen
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *apiUser;
    if([prefs objectForKey:@"apiUser"]) {
        apiUser = [[NSString alloc] initWithString:[prefs objectForKey:@"apiUser"]];
        [txtUser setStringValue:apiUser];
        
        //get the key from keychain
        [txtKey setStringValue:[AGKeychain getPasswordFromKeychainItem:RAX_MON_TASKBAR
                                                         withItemKind:RAX_MON_TASKBAR_ACCOUNT 
                                                          forUsername:apiUser]];
    }
    
    NSString *refreshRate;
    if([prefs objectForKey:@"refreshRate"]) {
        refreshRate = [[NSString alloc] initWithString:[prefs objectForKey:@"refreshRate"]];
        [btnRefreshRate selectItemWithTitle:refreshRate];
    }
    
    [NSApp activateIgnoringOtherApps:YES];
    [prefsWindow makeKeyAndOrderFront:sender];
    
}

-(IBAction) savePrefs:(id)sender {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
    [prefs setObject:[txtUser stringValue] forKey:@"apiUser"];
    [prefs setObject:[btnRefreshRate titleOfSelectedItem] forKey:@"refreshRate"];
    
    [prefs synchronize];
    
    //save the api key in the keychain
	if([AGKeychain checkForExistanceOfKeychainItem:RAX_MON_TASKBAR 
									  withItemKind:RAX_MON_TASKBAR_ACCOUNT 
									   forUsername:[txtUser stringValue]]) {
        
        [AGKeychain modifyKeychainItem:RAX_MON_TASKBAR 
                          withItemKind:RAX_MON_TASKBAR_ACCOUNT 
                           forUsername:[txtUser stringValue] 
                       withNewPassword:[txtKey stringValue]];
        
	}
	else {
		        
		[AGKeychain addKeychainItem:RAX_MON_TASKBAR 
					   withItemKind:RAX_MON_TASKBAR_ACCOUNT
						forUsername:[txtUser stringValue] 
					   withPassword:[txtKey stringValue]];
		
	}

    //save the timer
    timerRefresh = [[btnRefreshRate titleOfSelectedItem] integerValue] * 60.0;
    
    [updateTimer invalidate];
    [updateTimer release];
    updateTimer = nil;
    updateTimer = [[NSTimer 
                    scheduledTimerWithTimeInterval:(timerRefresh) 
                                                     target:self
                    selector:@selector(updateStatus:) 
                    userInfo:nil repeats:YES] retain];
                                                     
    
    [prefsWindow performClose:sender];
    
    [updateTimer fire];
}

-(IBAction)refreshRateChanged:(id)sender {
    
    if([[btnRefreshRate titleOfSelectedItem] isEqualToString:@"1"])
        [lblRefreshMinutes setStringValue:@"minute"];
    else 
        [lblRefreshMinutes setStringValue:@"minutes"];
    
    [lblRefreshMinutes setNeedsDisplay];
    
}

-(void) dealloc {
    [statusItem release];
    [menuIcon release];
    [updateTimer release];
    [super dealloc];
}

@end
