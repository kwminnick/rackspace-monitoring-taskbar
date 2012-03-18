//
//  MonMenulet.h
//  Rackspace Monitoring Taskbar
//
//  Created by Kevin Minnick on 3/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MonMenulet : NSObject {
    NSStatusItem *statusItem;
    NSImage *menuIcon;
    
    IBOutlet NSMenu *theMenu;
    NSMenuItem *monMenuItem;
    
    NSTimer *updateTimer;
    NSInteger timerRefresh;
    
    //monitoring window
    IBOutlet NSWindow *monWindow;
    
    //preferences window
    IBOutlet NSWindow *prefsWindow;
    IBOutlet NSTextField *txtUser;
    IBOutlet NSSecureTextField *txtKey;
    IBOutlet NSPopUpButton *btnRefreshRate;
    IBOutlet NSTextField *lblRefreshMinutes;
    
}

//menubar
-(IBAction) updateStatus:(id)sender;
-(IBAction) showPrefsWindow:(id)sender;
-(IBAction) showMonitoringWindow:(id)sender;

//preferences window
-(IBAction) savePrefs:(id)sender;
-(IBAction) refreshRateChanged:(id)sender;

@end
