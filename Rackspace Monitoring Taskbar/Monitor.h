//
//  Monitor.h
//  cloudmanager3
//
//  Created by Kevin Minnick on 10/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MonAlarm.h"

//check
@interface MonCheck : NSObject
{
	NSString *key;
	NSString *entityId;
	NSString *entityLabel;
	NSString *label;
	NSString *type;
	int timeout;
	int period;
	NSString *targetAlias;
	NSString *targetResolver;
	NSMutableArray *monitoringZones;
	NSMutableDictionary *options;
}

@property (copy, nonatomic) NSString *key, *entityId, *entityLabel, *label, *type, *targetAlias, *targetResolver;
@property int period, timeout;

-(void) addMonitoringZone: (NSString*) theZone;
-(NSArray*) getMonitoringZones;

-(void) addOption: (NSString*) theValue forKey: (NSString*) theKey;
-(NSDictionary*) getOptions;

@end

//zone
@interface MonZone : NSObject
{
	NSString *key;
	NSString *label;
}

@property (copy, nonatomic) NSString *key, *label;

@end

//entity
@interface MonEntity : NSObject {
	
	NSString *key;
	NSString *label;
	NSMutableArray *ipAddresses;
	NSMutableArray *metaData;
	NSArray *checks;

}

@property (copy, nonatomic) NSString *key, *label;

-(MonEntity*) initWithMonEntity: (MonEntity*) theEntity;

-(void) addIp:(NSString *) theIp withName: (NSString*) theName;
-(NSArray*) getIpAddresses;

-(void) setChecks:(NSArray*) theChecks;
-(NSArray*) getChecks;

@end

//ipaddress
@interface IpAddress : NSObject {
	NSString *name;
	NSString *ip;
}

@property (copy, nonatomic) NSString *name, *ip;

@end

//monitoring overview
@interface MonOverview : NSObject {
	MonEntity *entity;
	NSMutableArray *checks;
	NSMutableArray *alarms;
	NSMutableArray *alarmStates;
}

//entity
-(MonEntity*) getEntity;
-(void) setEntity: (MonEntity*) theEntity;

//checks
-(NSArray*) getChecks;
-(void) addCheck: (MonCheck*) theCheck;

//alarms
-(NSArray*) getAlarms;
-(void) addAlarm: (MonAlarm*) theAlarm;

//alarm states
-(NSArray*) getAlarmStates;
-(void) addAlarmState: (MonAlarmState*) theAlarmState;

@end