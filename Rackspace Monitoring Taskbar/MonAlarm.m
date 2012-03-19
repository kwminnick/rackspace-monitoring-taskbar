//
//  MonAlarm.m
//  cloudmanager3
//
//  Created by Kevin Minnick on 10/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MonAlarm.h"

@implementation MonAlarm

@synthesize key, entityId, entityLabel, checkType, criteria, notificationPlan;

-(void) dealloc {
	[key release];
	[entityId release];
	[checkType release];
	[criteria release];
	[notificationPlan release];
	[super dealloc];
}

@end


@implementation MonNotificationPlan

@synthesize key, label, criticalState, okState, warningState;

-(void) dealloc {
	[key release];
	[label release];
	[criticalState release];
	[okState release];
	[warningState release];
	[super dealloc];
}

@end


@implementation MonNotification

@synthesize key, label, url;

-(void) dealloc {
	[label release];
	[key release];
	[url release];
	[super dealloc];
}

@end

@implementation MonAlarmState

@synthesize timestamp, entityId, alarmId, checkId, state, monZoneId;

-(void) dealloc {
	[timestamp release];
	[entityId release];
	[alarmId release];
	[checkId release];
	[state release];
	[monZoneId release];
	[super dealloc];
}

@end