//
//  Rackspace_Monitoring_TaskbarAppDelegate.h
//  Rackspace Monitoring Taskbar
//
//  Created by Kevin Minnick on 3/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Rackspace_Monitoring_TaskbarAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    NSPersistentStoreCoordinator *__persistentStoreCoordinator;
    NSManagedObjectModel *__managedObjectModel;
    NSManagedObjectContext *__managedObjectContext;
}

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
