//
//  Monitor.m
//  cloudmanager3
//
//  Created by Kevin Minnick on 10/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Monitor.h"
#import "constants.h"

@implementation MonCheck

@synthesize key, entityId, entityLabel, label, type, targetAlias, targetResolver;
@synthesize period, timeout;

-(MonCheck*) init {
	self = [super init];
	monitoringZones = [[NSMutableArray alloc] init];
	options = [[NSMutableDictionary alloc] init];
	return self;
}

-(void) addMonitoringZone:(NSString *)theZone {
	[monitoringZones addObject:theZone];
}

-(NSArray*) getMonitoringZones {
	return monitoringZones;
}

-(void) addOption:(NSString *)theValue forKey:(NSString *)theKey {
	[options setObject:[NSString stringWithString:theValue] forKey:[NSString stringWithString:theKey]];
}

-(NSDictionary*) getOptions {
	return options;
}

-(void) dealloc {
	[monitoringZones release];
	[options release];
	[key release];
	[entityId release];
	[label release];
	[type release];
	[targetAlias release];
	[targetResolver release];
	[super dealloc];
}

@end


@implementation MonZone

@synthesize key, label;

-(void) dealloc {
	[key release];
	[label release];
	[super dealloc];
}


@end


@implementation MonEntity

@synthesize key, label;

-(id) init {
	return [self initWithMonEntity: nil];
}

-(MonEntity*) initWithMonEntity: (MonEntity*) theEntity {
	
	self = [super init];
	
	ipAddresses = [[NSMutableArray alloc] init];
	metaData = [[NSMutableArray alloc] init];
	
	if(theEntity) {
		[self setKey:theEntity.key];
		[self setLabel:theEntity.label];
		for(IpAddress* ip in [theEntity getIpAddresses])
			[self addIp:ip.ip withName:ip.name];
	}
	
	return self;		
}

-(void) addIp:(NSString *) theIp withName: (NSString*) theName {
	IpAddress *ip = [[IpAddress alloc] init];
	[ip setName: theName];
	[ip setIp: theIp];
	[ipAddresses addObject: ip];
	[ip release];
}

-(NSArray*) getIpAddresses {
	return ipAddresses;
}

-(void) setChecks:(NSArray *)theChecks {
	checks = [[NSArray alloc] initWithArray:theChecks];
}

-(NSArray*) getChecks {
	return checks;
}

-(void) dealloc {
	[key release];
	[label release];
	[ipAddresses release];
	[metaData release];
	[checks release];
	[super dealloc];
}

@end

//ipaddress
@implementation IpAddress

@synthesize name, ip;

-(void) dealloc {
	[name release];
	[ip release];
	[super dealloc];
}

@end


//overview
@implementation MonOverview

-(id) init {
	self = [super init];
	entity = nil;
	checks = nil;
	alarms = nil;
	alarmStates = nil;
	return self;
}

-(void) setEntity: (MonEntity*) theEntity {
	entity = [[[MonEntity alloc] initWithMonEntity:theEntity] retain];
}

-(MonEntity*) getEntity {
	MonEntity *retEntity = [[MonEntity alloc] initWithMonEntity:entity];	
	return [retEntity autorelease];
}

-(NSArray*) getChecks {
	return checks;
}

-(void) addCheck: (MonCheck*) theCheck {

	if(!theCheck)
		return;

	if(!checks)
		checks = [[NSMutableArray alloc] init];
	
	[checks addObject:theCheck];
}

-(NSArray*) getAlarms {
	return alarms;
}

-(void) addAlarm: (MonAlarm*) theAlarm {
	
	if(!theAlarm)
		return;
	
	if(!alarms)
		alarms = [[NSMutableArray alloc] init];
	
	[alarms addObject:theAlarm];
}

-(NSArray*) getAlarmStates {
	return alarmStates;
}

-(void) addAlarmState:(MonAlarmState *)theAlarmState {
	if(!theAlarmState)
		return;
	
	if(!alarmStates)
		alarmStates = [[NSMutableArray alloc] init];
	
	[alarmStates addObject:theAlarmState];
}

-(void) dealloc {
	[entity release];
	[checks release];
	[alarms release];
	[alarmStates release];
	[super dealloc];
}

@end

