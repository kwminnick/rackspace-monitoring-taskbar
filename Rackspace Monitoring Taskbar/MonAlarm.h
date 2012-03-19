//
//  MonAlarm.h
//  cloudmanager3
//
//  Created by Kevin Minnick on 10/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MonAlarm : NSObject
{
	NSString *key;
	NSString *entityId;
	NSString *entityLabel;
	NSString *checkType;
	NSString *criteria;
	NSString *notificationPlan;
}

@property (copy, nonatomic) NSString *key, *entityId, *entityLabel, *checkType, *criteria, *notificationPlan;

@end


@interface MonNotificationPlan : NSObject
{
	NSString *key;
	NSString *label;
	NSString *criticalState;
	NSString *okState;
	NSString *warningState;
}

@property (copy, nonatomic) NSString *key, *label, *criticalState, *okState, *warningState;

@end


@interface MonNotification : NSObject {

	NSString *key;
	NSString *label;
	NSString *url;

}

@property (copy, nonatomic) NSString *key, *label, *url;

@end


@interface MonAlarmState : NSObject {
	NSString *timestamp;
	NSString *entityId;
	NSString *alarmId;
	NSString *checkId;
	NSString *state;
	NSString *monZoneId;
}

@property (copy, nonatomic) NSString *timestamp, *entityId, *alarmId, *checkId, *state, *monZoneId;

@end