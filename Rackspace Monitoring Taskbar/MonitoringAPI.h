//
//  MonitoringAPI.h
//  cloudmanager3
//
//  Created by Kevin Minnick on 10/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseAPI.h"

@interface MonitoringAPI : BaseAPI {
    NSString *endPoint;
}

//entities
-(NSArray*) listEntities;
-(void) createEntity: (NSString*) label withIps: (NSArray*) ips withMetaData: (NSArray*) metaData;
-(void) deleteEntity: (NSString*) key;

//checks
-(void) createCheck: (NSString*) label 
	   withEntityId: (NSString*) entityId 
		   withType: (NSString*) type 
withMonitoringZones: (NSArray*) zones 
		withTimeout: (int) timeout 
		 withPeriod: (int) period 
	withTargetAlias: (NSString*) targetAlias
		withOptions: (NSDictionary*) options;

-(NSArray*) listChecks: (NSString*) entityId;
-(void) deleteCheck: (NSString*) key withEntityId: (NSString*) entityId;

-(void) testCheck: (NSString*) key 
		  withEntityId: (NSString*) entityId 
		  withDelegate: (id) delegate 
 withDidFinishSelector: (SEL) didFinishSelector 
   withDidFailSelector: (SEL) didFailSelector;

//monitoring zones
-(NSArray*) listMonitoringZones;

//notifications
-(void) createNotification: (NSString*) label withUrl: (NSString*) url;
-(NSArray*) listNotifications;
-(void) deleteNotification: (NSString*) key;

//notification plans
-(void) createNotificationPlan: (NSString*) label 
				withErrorState: (NSString*) errorState 
				   withOkState: (NSString*) okState 
			  withWarningState: (NSString*) warningState;
-(NSArray*) listNotificationPlans;
-(void) deleteNotificationPlan: (NSString*) key;

//alarms
-(void) createAlarm: (NSString*) entityId 
	  withCheckType: (NSString*) checkType 
	   withCriteria: (NSString*) criteria 
withNotificationPlan: (NSString*) notificationPlan;
-(NSArray*) listAlarms: (NSString*) entityId;
-(void) deleteAlarm: (NSString*) key withEntityId: (NSString*) entityId;

//views
-(NSArray*) getOverviews;

@end
