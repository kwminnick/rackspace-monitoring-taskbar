//
//  MonitoringAPI.m
//  cloudmanager3
//
//  Created by Kevin Minnick on 10/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MonitoringAPI.h"
#import "constants.h"
#import "NetworkUtils.h"
#import "Monitor.h"
#import "MonAlarm.h"
#import "CloudManagerUtils.h"

@implementation MonitoringAPI

-(id) init {
    self = [super init];
    endPoint = [[NSString alloc] initWithFormat:@"%@/%@", RACKSPACE_MON_URL, authToken.tenantId];
    return self;
}

-(MonEntity*) parseMonEntityElement: (NSXMLElement*) xmlElement {
	
	MonEntity *entity = [[MonEntity alloc] init];
	
	//label
	NSArray *labels = [xmlElement nodesForXPath:@"label" error:nil];
	NSString *label;
	if(labels) {
		label = [[labels objectAtIndex:0] stringValue];
	}
	else
		label = @"n/a";
	[entity setLabel:label];
	
	//key
	NSString *key = [[xmlElement attributeForName:@"id"] stringValue];
	if(key)
		[entity setKey:key];
	else
		[entity setKey:@""];
	
	//ip_addresses
	NSArray *ipAddresses = [xmlElement nodesForXPath:@"ip_addresses" error:nil];
	if(ipAddresses) {
		for(NSXMLNode *ipNode in [[ipAddresses objectAtIndex:0] children]) {
			NSString *ip = [ipNode stringValue];
			NSString *ipNodeName = [ipNode name];
			if(ip)
				[entity addIp: ip withName: ipNodeName];
		}
	}
	
	return [entity autorelease];
}

-(MonCheck*) parseMonCheckElement:(NSXMLElement *)xmlElement {
	
	MonCheck *check = [[MonCheck alloc] init];
		
	//label
	NSArray *labels = [xmlElement nodesForXPath:@"label" error:nil];
	NSString *label;
	if(labels) {
		label = [[labels objectAtIndex:0] stringValue];
	}
	else
		label = @"n/a";
	[check setLabel:label];
	
	//key
	NSString *key = [[xmlElement attributeForName:@"id"] stringValue];
	if(key)
		[check setKey:key];
	else
		[check setKey:@""];
	
	//type
	NSArray *types = [xmlElement nodesForXPath:@"type" error:nil];
	NSString *type;
	if(types) {
		type = [[types objectAtIndex:0] stringValue];
	}
	else
		type = @"";
	[check setType:type];
	
	//timeout
	NSArray *timeouts = [xmlElement nodesForXPath:@"timeout" error:nil];
	NSString *timeout;
	if(timeouts) {
		timeout = [[timeouts objectAtIndex:0] stringValue];
	}
	else
		timeout = @"0";
	[check setTimeout:[timeout intValue]];
	
	//period
	NSArray *periods = [xmlElement nodesForXPath:@"period" error:nil];
	NSString *period;
	if(periods) {
		period = [[periods objectAtIndex:0] stringValue];
	}
	else
		period = @"0";
	[check setPeriod:[period intValue]];
	
	//target alias
	NSArray *targetAliases = [xmlElement nodesForXPath:@"target_alias" error:nil];
	NSString *targetAlias;
	if(targetAliases) {
		targetAlias = [[targetAliases objectAtIndex:0] stringValue];
	}
	else
		targetAlias = @"";
	[check setTargetAlias:targetAlias];
	
	//target resolver
	NSArray *targetResolvers = [xmlElement nodesForXPath:@"target_resolver" error:nil];
	NSString *targetResolver;
	if(targetResolvers) {
		targetResolver = [[targetResolvers objectAtIndex:0] stringValue];
	}
	else
		targetResolver = @"";
	[check setTargetResolver:targetResolver];
	
	//monitoring zones
	NSArray *mZones = [xmlElement nodesForXPath:@"monitoring_zones_poll" error:nil];
	if(mZones) {
		for(NSXMLNode *mZone in [[mZones objectAtIndex:0] children]) {
			NSString *zoneName = [mZone stringValue];
			if(zoneName)
				[check addMonitoringZone:zoneName];
		}
	}
	
	//details (options)
	NSArray *optionsArr = [xmlElement nodesForXPath:@"details" error:nil];
	if(optionsArr) {
		for(NSXMLNode *optionNode in [[optionsArr objectAtIndex:0] children]) {
			NSString *optionValue = [optionNode stringValue];
			NSString *optionKey = [optionNode name];
			if(optionValue)
				[check addOption:optionValue forKey:optionKey];
		}
	}

	return [check autorelease];
}

-(MonAlarm*) parseMonAlarmElement: (NSXMLElement*) xmlElement {
	
	MonAlarm *alarm = [[MonAlarm alloc] init];
	
	//check type
	NSArray *checkTypes = [xmlElement nodesForXPath:@"check_type" error:nil];
	NSString *checkType;
	if(checkTypes) {
		checkType = [[checkTypes objectAtIndex:0] stringValue];
	}
	else
		checkType = @"";
	[alarm setCheckType:checkType];
	
	//key
	NSString *key = [[xmlElement attributeForName:@"id"] stringValue];
	if(key)
		[alarm setKey:key];
	else
		[alarm setKey:@""];
	
	//criteria
	NSArray *criterias = [xmlElement nodesForXPath:@"criteria" error:nil];
	NSString *criteria;
	if(criterias) {
		criteria = [[criterias objectAtIndex:0] stringValue];
	}
	else
		criteria = @"";
	[alarm setCriteria:criteria];
	
	//notification_plan_id
	NSArray *notification_plan_ids = [xmlElement nodesForXPath:@"notification_plan_id" error:nil];
	NSString *notification_plan_id;
	if(notification_plan_ids) {
		notification_plan_id = [[notification_plan_ids objectAtIndex:0] stringValue];
	}
	else
		notification_plan_id = @"";
	[alarm setNotificationPlan:notification_plan_id];
	
	return [alarm autorelease];
	
}

-(NSArray*) listEntities {
	
	NSString* urlString = ENTITIES_URL;
	ASIHTTPRequest *request = [NetworkUtils getConnection:urlString
											withAuthToken:authToken
                                             withEndPoint:endPoint];
	
	if(!request) {
		[CloudManagerUtils CMLog:@"Failed to get request object."];
		return nil;
	}
	
	[request startSynchronous];
	NSError *error = [request error];
	
	NSMutableArray* entities = [[[NSMutableArray alloc] init] autorelease];
	
	if (error) {
		[CloudManagerUtils CMLog:@"Request %@", [request responseString]];
		[CloudManagerUtils CMLog:@"Error %@", error];
		return nil;
	}
	
	int statusCode = [request responseStatusCode];
	[CloudManagerUtils CMLog:@"Response Headers: %@", [request responseHeaders]];
	[CloudManagerUtils CMLog:@"Status Code: %i", statusCode];
		
	if(!(statusCode == 200 || statusCode == 203))
		return nil;
		
	// Use when fetching binary data
	NSData *responseData = [request responseData];
	NSString *strData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
		
	[CloudManagerUtils CMLog:@"Data: %s", [strData UTF8String]];
		
	//parse the xml
	NSXMLDocument* doc = [[NSXMLDocument alloc] initWithData:responseData options:0 error:nil];
		
	NSXMLElement* root  = [doc rootElement];
		
	NSArray* serverArray = [root nodesForXPath:@"//entity" error:nil];
	for(NSXMLElement* xmlElement in serverArray) {
		MonEntity *entity = [self parseMonEntityElement: xmlElement];				
		[entities addObject:entity];
	}
	
	[doc release];
	[strData release];
	
	return entities;
}

-(void) createEntity: (NSString*) label withIps: (NSArray*) ips withMetaData: (NSArray*) metaData {
	
	NSString* urlString = ENTITIES_URL;
	
	NSMutableString *ipStr = [[NSMutableString alloc] init];
	for(IpAddress* ip in ips) {
		[ipStr appendFormat:@"<%@>%@</%@>", ip.name, ip.ip, ip.name];
	}

	NSString* postData = [NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
						  "<entity>"
						  "<label>%@</label>"
						  "<ip_addresses>"
							"%@"
						  "</ip_addresses>"
						  "</entity>", label, ipStr];
	
	ASIHTTPRequest *request = [NetworkUtils getConnection:urlString
											withAuthToken:authToken 
											 withEndPoint:endPoint];
    
	[request appendPostData:[postData dataUsingEncoding:NSUTF8StringEncoding]];
	[request setRequestMethod:@"POST"];
	
	[CloudManagerUtils CMLog:@"Request Headers: %@", [request requestHeaders]];
	[CloudManagerUtils CMLog:@"Post Body: %s", [postData UTF8String]];
	
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestDone:)];
	[request setDidFailSelector:@selector(requestFailed:)];
	[request startAsynchronous];
	
}

-(void) deleteEntity: (NSString*) key {

	if([key length] < 1) {
		return;
	}
	//first get a list of checks and delete the checks
	NSArray *checks = [self listChecks: key];
	if(checks) {
		for(MonCheck* check in checks)
			[self deleteCheck:check.key withEntityId:key];
	}
	
	//second delete the alarms
	NSArray *alarms = [self listAlarms:key];
	if(alarms) {
		for(MonAlarm *alarm in alarms)
			[self deleteAlarm:alarm.key withEntityId:key];
	}
	
	//now delete the entity
	NSString* urlString = [NSString stringWithFormat:@"%@/%@", ENTITIES_URL, key];
	
	ASIHTTPRequest *request = [NetworkUtils getConnection:urlString
											withAuthToken:authToken 
											 withEndPoint:endPoint];
	
	[request setRequestMethod:@"DELETE"];
	
	[CloudManagerUtils CMLog:@"Request Headers: %@", [request requestHeaders]];
	
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestDone:)];
	[request setDidFailSelector:@selector(requestFailed:)];
	[request startAsynchronous];
	
}

-(void) createCheck: (NSString*) label 
	   withEntityId: (NSString*) entityId 
		   withType: (NSString*) type 
withMonitoringZones: (NSArray*) zones 
		withTimeout: (int) timeout 
		 withPeriod: (int) period 
	withTargetAlias: (NSString*) targetAlias
		withOptions: (NSDictionary*) options {

	NSString* urlString = [NSString stringWithFormat:@"%@/%@/checks", ENTITIES_URL, entityId];
	
	NSMutableString *zonesStr = [[NSMutableString alloc] init];
	for(MonZone* zone in zones) {
		[zonesStr appendFormat:@"<monitoring_zone_id>%@</monitoring_zone_id>", zone.key];
	}
	
	NSMutableString *optionsStr = [[NSMutableString alloc] initWithString:@""];
	if(options) {
		[optionsStr appendString:@"<details>"];
		for(NSString* option in options) {
			NSString* value = [options objectForKey:option];
			[optionsStr appendFormat:@"<%@>%@</%@>", option, value, option];
		}
		[optionsStr appendString:@"</details>"];
	}
	
	NSString* postData = [NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
						  "<check>"
						  "<label>%@</label>"
						  "<type>%@</type>"
						  "%@"
						  "<monitoring_zones_poll>"
						  "%@"
						  "</monitoring_zones_poll>"
						  "<timeout>%d</timeout>"
						  "<period>%d</period>"
						  "<target_alias>%@</target_alias>"
						  "</check>", label, type, optionsStr, zonesStr, timeout, period, targetAlias];
	
	ASIHTTPRequest *request = [NetworkUtils getConnection:urlString
											withAuthToken:authToken 
											 withEndPoint:endPoint];
	[request appendPostData:[postData dataUsingEncoding:NSUTF8StringEncoding]];
	[request setRequestMethod:@"POST"];
	
	[CloudManagerUtils CMLog:@"Request Headers: %@", [request requestHeaders]];
	[CloudManagerUtils CMLog:@"Post Body: %s", [postData UTF8String]];
	
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestDone:)];
	[request setDidFailSelector:@selector(requestFailed:)];
	[request startAsynchronous];	
	
}

-(NSArray*) listChecks: (NSString*) entityId {
	
	NSString* urlString = [NSString stringWithFormat:@"%@/%@%@", ENTITIES_URL, entityId, CHECKS_URL];
	ASIHTTPRequest *request = [NetworkUtils getConnection:urlString
											withAuthToken:authToken 
											 withEndPoint:endPoint];
	
	if(!request) {
		[CloudManagerUtils CMLog:@"Failed to get request object."];
		return nil;
	}
	
	[request startSynchronous];
	NSError *error = [request error];
	
	NSMutableArray* checks = [[[NSMutableArray alloc] init] autorelease];
	
	if (error) {
		[CloudManagerUtils CMLog:@"Request %@", [request responseString]];
		[CloudManagerUtils CMLog:@"Error %@", error];
		return nil;
	}
	
	int statusCode = [request responseStatusCode];
	[CloudManagerUtils CMLog:@"Response Headers: %@", [request responseHeaders]];
	[CloudManagerUtils CMLog:@"Status Code: %i", statusCode];
	
	if(!(statusCode == 200 || statusCode == 203))
		return nil;
	
	// Use when fetching binary data
	NSData *responseData = [request responseData];
	NSString *strData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	
	[CloudManagerUtils CMLog:@"Data: %s", [strData UTF8String]];
	
	//parse the xml
	NSXMLDocument* doc = [[NSXMLDocument alloc] initWithData:responseData options:0 error:nil];
	
	NSXMLElement* root  = [doc rootElement];
	
	NSArray* checkArray = [root nodesForXPath:@"//check" error:nil];
	for(NSXMLElement* xmlElement in checkArray) {
		
		MonCheck *check = [self parseMonCheckElement: xmlElement];
		[check setEntityId:entityId];
		[checks	addObject:check];
		
	}
	
	[doc release];
	[strData release];
	
	return checks;
}


-(NSArray*) listMonitoringZones {
	
	NSString* urlString = MONITORING_ZONES_URL;
	ASIHTTPRequest *request = [NetworkUtils getConnection:urlString
											withAuthToken:authToken 
											 withEndPoint:endPoint];
	
	if(!request) {
		[CloudManagerUtils CMLog:@"Failed to get request object."];
		return nil;
	}
	
	[request startSynchronous];
	NSError *error = [request error];
	
	NSMutableArray* zones = [[[NSMutableArray alloc] init] autorelease];
	
	if (error) {
		[CloudManagerUtils CMLog:@"Request %@", [request responseString]];
		[CloudManagerUtils CMLog:@"Error %@", error];
		return nil;
	}
	
	int statusCode = [request responseStatusCode];
	[CloudManagerUtils CMLog:@"Response Headers: %@", [request responseHeaders]];
	[CloudManagerUtils CMLog:@"Status Code: %i", statusCode];
	
	if(!(statusCode == 200 || statusCode == 203))
		return nil;
	
	// Use when fetching binary data
	NSData *responseData = [request responseData];
	NSString *strData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	
	[CloudManagerUtils CMLog:@"Data: %s", [strData UTF8String]];
	
	//parse the xml
	NSXMLDocument* doc = [[NSXMLDocument alloc] initWithData:responseData options:0 error:nil];
	
	NSXMLElement* root  = [doc rootElement];
	
	NSArray* zoneArray = [root nodesForXPath:@"//monitoring_zone" error:nil];
	for(NSXMLElement* xmlElement in zoneArray) {
		MonZone	*zone = [[MonZone alloc] init];
		
		//label
		NSArray *labels = [xmlElement nodesForXPath:@"label" error:nil];
		NSString *label;
		if(labels) {
			label = [[labels objectAtIndex:0] stringValue];
		}
		else
			label = @"n/a";
		[zone setLabel:label];
		
		//key
		NSString *key = [[xmlElement attributeForName:@"id"] stringValue];
		if(key)
			[zone setKey:key];
		else
			[zone setKey:@""];
				
		[zones addObject:zone];
		[zone release];
	}
	
	[doc release];
	[strData release];
	
	return zones;
}

-(void) deleteCheck: (NSString*) key withEntityId: (NSString*) entityId {
	
	if([key length] < 1) {
		return;
	}
	
	NSString* urlString = [NSString stringWithFormat:@"%@/%@/checks/%@", ENTITIES_URL, entityId, key];
	
	ASIHTTPRequest *request = [NetworkUtils getConnection:urlString
											withAuthToken:authToken 
											 withEndPoint:endPoint];
	
	[request setRequestMethod:@"DELETE"];
	
	[CloudManagerUtils CMLog:@"Request Headers: %@", [request requestHeaders]];
	
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestDone:)];
	[request setDidFailSelector:@selector(requestFailed:)];
	[request startAsynchronous];
	
}

-(void) testCheck: (NSString*) key 
		  withEntityId: (NSString*) entityId
		  withDelegate: (id) delegate 
 withDidFinishSelector: (SEL) didFinishSelector 
   withDidFailSelector: (SEL) didFailSelector {

	if([key length] < 1 || [entityId length] < 1)
		return;
	
	NSArray *checks = [self listChecks:entityId];
	MonCheck *theCheck = nil;
	for(MonCheck *check in checks) {
		if([check.key isEqualToString:key]) {
			theCheck = check;
			break;
		}
	}
	if(!theCheck)
		return;
	
	NSMutableString *zonesStr = [[NSMutableString alloc] init];
	for(NSString* zone in [theCheck getMonitoringZones]) {
		[zonesStr appendFormat:@"<monitoring_zone_id>%@</monitoring_zone_id>", zone];
	}
	
	NSMutableString *optionsStr = [[NSMutableString alloc] initWithString:@""];
	NSDictionary *options = [theCheck getOptions];
	if(options && ([options count] > 0)) {
		[optionsStr appendString:@"<details>"];
		for(NSString* option in options) {
			NSString* value = [options objectForKey:option];
			[optionsStr appendFormat:@"<%@>%@</%@>", option, value, option];
		}
		[optionsStr appendString:@"</details>"];
	}	
	
	NSString* postData = [NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
						  "<check>"
						  "<type>%@</type>"
						  "%@"
						  "<monitoring_zones_poll>"
						  "%@"
						  "</monitoring_zones_poll>"
						  "<timeout>%d</timeout>"
						  "<target_alias>%@</target_alias>"
						  "</check>", theCheck.type, optionsStr, zonesStr, theCheck.timeout, theCheck.targetAlias];
	
	
	NSString* urlString = [NSString stringWithFormat:@"%@/%@%@", ENTITIES_URL, entityId, TEST_CHECK_URL];
	
	ASIHTTPRequest *request = [NetworkUtils getConnection:urlString
											withAuthToken:authToken 
											 withEndPoint:endPoint];
	
	[request appendPostData:[postData dataUsingEncoding:NSUTF8StringEncoding]];
	[request setRequestMethod:@"POST"];
	
	[CloudManagerUtils CMLog:@"Request Headers: %@", [request requestHeaders]];
	[CloudManagerUtils CMLog:@"Post Body: %s", [postData UTF8String]];
	
	[request setDelegate:delegate];
	[request setDidFinishSelector:didFinishSelector];
	[request setDidFailSelector:didFailSelector];
	[request startAsynchronous];
			
}

-(void) createNotification: (NSString*) label withUrl: (NSString*) url {

	NSString* urlString = [NSString stringWithFormat:@"%@", NOTIFICATIONS_URL];
		
	NSString* postData = [NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
						  "<notification>"
						  "<label>%@</label>"
						  "<type>webhook</type>"
						  "<details>"
						  "<url>%@</url>"
						  "</details>"
						  "</notification>", label, url];
	
	ASIHTTPRequest *request = [NetworkUtils getConnection:urlString
											withAuthToken:authToken 
											 withEndPoint:endPoint];
	[request appendPostData:[postData dataUsingEncoding:NSUTF8StringEncoding]];
	[request setRequestMethod:@"POST"];
	
	[CloudManagerUtils CMLog:@"Request Headers: %@", [request requestHeaders]];
	[CloudManagerUtils CMLog:@"Post Body: %s", [postData UTF8String]];
	
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestDone:)];
	[request setDidFailSelector:@selector(requestFailed:)];
	[request startAsynchronous];	
	
}

-(NSArray*) listNotifications {
	
	NSString* urlString = NOTIFICATIONS_URL;
	ASIHTTPRequest *request = [NetworkUtils getConnection:urlString
											withAuthToken:authToken 
											 withEndPoint:endPoint];
	
	if(!request) {
		[CloudManagerUtils CMLog:@"Failed to get request object."];
		return nil;
	}
	
	[request startSynchronous];
	NSError *error = [request error];
	
	NSMutableArray* notifications = [[[NSMutableArray alloc] init] autorelease];
	
	if (error) {
		[CloudManagerUtils CMLog:@"Response: %@", [request responseString]];
		[CloudManagerUtils CMLog:@"Error %@", error];
		return nil;
	}
	
	int statusCode = [request responseStatusCode];
	[CloudManagerUtils CMLog:@"Response Headers: %@", [request responseHeaders]];
	[CloudManagerUtils CMLog:@"Status Code: %i", statusCode];
	
	if(!(statusCode == 200 || statusCode == 203))
		return nil;
	
	// Use when fetching binary data
	NSData *responseData = [request responseData];
	NSString *strData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	
	[CloudManagerUtils CMLog:@"Data: %s", [strData UTF8String]];
	
	//parse the xml
	NSXMLDocument* doc = [[NSXMLDocument alloc] initWithData:responseData options:0 error:nil];
	
	NSXMLElement* root  = [doc rootElement];
	
	NSArray* notArray = [root nodesForXPath:@"//notification" error:nil];
	for(NSXMLElement* xmlElement in notArray) {
		MonNotification	*notification = [[MonNotification alloc] init];
		
		//label
		NSArray *labels = [xmlElement nodesForXPath:@"label" error:nil];
		NSString *label;
		if(labels) {
			label = [[labels objectAtIndex:0] stringValue];
		}
		else
			label = @"";
		[notification setLabel:label];
		
		//key
		NSString *key = [[xmlElement attributeForName:@"id"] stringValue];
		if(key)
			[notification setKey:key];
		else
			[notification setKey:@""];
		
		//url
		NSArray *urls = [xmlElement nodesForXPath:@"details" error:nil];
		if(urls) {
			NSXMLNode *urlNode = [urls objectAtIndex:0];
			if(urlNode) {
				NSString *url = [urlNode stringValue];
				if(url)
					[notification setUrl: url];
			}
		}
		
		[notifications addObject:notification];
		[notification release];
	}
	
	[doc release];
	[strData release];
	
	return notifications;
	
}

-(void) deleteNotification: (NSString*) key {

	if([key length] < 1) {
		return;
	}
	
	NSString* urlString = [NSString stringWithFormat:@"%@/%@", NOTIFICATIONS_URL, key];
	
	ASIHTTPRequest *request = [NetworkUtils getConnection:urlString
											withAuthToken:authToken 
											 withEndPoint:endPoint];
	
	[request setRequestMethod:@"DELETE"];
	
	[CloudManagerUtils CMLog:@"Request Headers: %@", [request requestHeaders]];
	
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestDone:)];
	[request setDidFailSelector:@selector(requestFailed:)];
	[request startAsynchronous];
	
}

-(void) createNotificationPlan: (NSString*) label 
				withErrorState: (NSString*) errorState 
				   withOkState: (NSString*) okState 
			  withWarningState: (NSString*) warningState {
	

	NSString* urlString = [NSString stringWithFormat:@"%@", NOTIFICATION_PLANS_URL];
	
	NSString* postData = [NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
						  "<notification_plan>"
						  "<label>%@</label>"
						  "<critical_state><notification_id>%@</notification_id></critical_state>"
						  "<warning_state><notification_id>%@</notification_id></warning_state>"
						  "<ok_state><notification_id>%@</notification_id></ok_state>"
						  "</notification_plan>", label, errorState, warningState, okState];
	
	ASIHTTPRequest *request = [NetworkUtils getConnection:urlString
											withAuthToken:authToken 
											 withEndPoint:endPoint];
	[request appendPostData:[postData dataUsingEncoding:NSUTF8StringEncoding]];
	[request setRequestMethod:@"POST"];
	
	[CloudManagerUtils CMLog:@"Request Headers: %@", [request requestHeaders]];
	[CloudManagerUtils CMLog:@"Post Body: %s", [postData UTF8String]];
	
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestDone:)];
	[request setDidFailSelector:@selector(requestFailed:)];
	[request startAsynchronous];	
	
}

-(NSArray*) listNotificationPlans {
	
	NSString* urlString = NOTIFICATION_PLANS_URL;
	ASIHTTPRequest *request = [NetworkUtils getConnection:urlString
											withAuthToken:authToken 
											 withEndPoint:endPoint];
	
	if(!request) {
		[CloudManagerUtils CMLog:@"Failed to get request object."];
		return nil;
	}
	
	[request startSynchronous];
	NSError *error = [request error];
	
	NSMutableArray* notificationPlans = [[[NSMutableArray alloc] init] autorelease];
	
	if (error) {
		[CloudManagerUtils CMLog:@"Response: %@", [request responseString]];
		[CloudManagerUtils CMLog:@"Error %@", error];
		return nil;
	}
	
	int statusCode = [request responseStatusCode];
	[CloudManagerUtils CMLog:@"Response Headers: %@", [request responseHeaders]];
	[CloudManagerUtils CMLog:@"Status Code: %i", statusCode];
	
	if(!(statusCode == 200 || statusCode == 203))
		return nil;
	
	// Use when fetching binary data
	NSData *responseData = [request responseData];
	NSString *strData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	
	[CloudManagerUtils CMLog:@"Data: %s", [strData UTF8String]];
	
	//parse the xml
	NSXMLDocument* doc = [[NSXMLDocument alloc] initWithData:responseData options:0 error:nil];
	
	NSXMLElement* root  = [doc rootElement];
	
	NSArray* notArray = [root nodesForXPath:@"//notification_plan" error:nil];
	for(NSXMLElement* xmlElement in notArray) {
		MonNotificationPlan	*notificationPlan = [[MonNotificationPlan alloc] init];
		
		//label
		NSArray *labels = [xmlElement nodesForXPath:@"label" error:nil];
		NSString *label;
		if(labels) {
			label = [[labels objectAtIndex:0] stringValue];
		}
		else
			label = @"";
		[notificationPlan setLabel:label];
		
		//key
		NSString *key = [[xmlElement attributeForName:@"id"] stringValue];
		if(key)
			[notificationPlan setKey:key];
		else
			[notificationPlan setKey:@""];
		
		//critical_state
		NSArray *criticalArray = [xmlElement nodesForXPath:@"critical_state" error:nil];
		NSString *criticalState = @"";
		if(criticalArray) {
			if([criticalArray count] > 0) {
				for(NSXMLNode *criticalNode in [[criticalArray objectAtIndex:0] children]) {
					criticalState = [criticalNode stringValue];
				}
			}
		}
		[notificationPlan setCriticalState:criticalState];
		
		//warning_state
		NSArray *warningArray = [xmlElement nodesForXPath:@"warning_state" error:nil];
		NSString *warningState = @"";
		if(warningArray) {
			for(NSXMLNode *warningNode in [[warningArray objectAtIndex:0] children]) {
				warningState = [warningNode stringValue];
			}
		}
		[notificationPlan setWarningState:warningState];

		//ok_state
		NSArray *okArray = [xmlElement nodesForXPath:@"ok_state" error:nil];
		NSString *okState;
		if(okArray) {
			for(NSXMLNode *okNode in [[okArray objectAtIndex:0] children]) {
				okState = [okNode stringValue];
			}
		}
		[notificationPlan setOkState: okState];
		
		[notificationPlans addObject:notificationPlan];
		[notificationPlan release];
	}
	
	[doc release];
	[strData release];
	
	return notificationPlans;
	
}

-(void) deleteNotificationPlan: (NSString*) key {
	
	if([key length] < 1) {
		return;
	}
	
	NSString* urlString = [NSString stringWithFormat:@"%@/%@", NOTIFICATION_PLANS_URL, key];
	
	ASIHTTPRequest *request = [NetworkUtils getConnection:urlString
											withAuthToken:authToken 
											 withEndPoint:endPoint];
	
	[request setRequestMethod:@"DELETE"];
	
	[CloudManagerUtils CMLog:@"Request Headers: %@", [request requestHeaders]];
	
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestDone:)];
	[request setDidFailSelector:@selector(requestFailed:)];
	[request startAsynchronous];
	
}

-(void) createAlarm: (NSString*) entityId 
	  withCheckType: (NSString*) checkType 
	   withCriteria: (NSString*) criteria 
withNotificationPlan: (NSString*) notificationPlan {

	NSString* urlString = [NSString stringWithFormat:@"%@/%@/alarms", ENTITIES_URL, entityId];
	
	NSString *criteriaStr;
	if(!criteria || [criteria isEqualToString:@""])
		criteriaStr = @"";
	else
		criteriaStr = [NSString stringWithFormat:@"<criteria>%@</criteria>", criteria];

	NSString* postData = [NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
						  "<alarm>"
						  "<check_type>%@</check_type>"
						  "%@"
						  "<notification_plan_id>%@</notification_plan_id>"
						  "</alarm>", checkType, criteriaStr, notificationPlan];
	
	ASIHTTPRequest *request = [NetworkUtils getConnection:urlString
											withAuthToken:authToken 
											 withEndPoint:endPoint];

	[request appendPostData:[postData dataUsingEncoding:NSUTF8StringEncoding]];
	[request setRequestMethod:@"POST"];
	
	[CloudManagerUtils CMLog:@"Request Headers: %@", [request requestHeaders]];
	[CloudManagerUtils CMLog:@"Post Body: %s", [postData UTF8String]];
	
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestDone:)];
	[request setDidFailSelector:@selector(requestFailed:)];
	[request startAsynchronous];	

}

-(NSArray*) listAlarms: (NSString*) entityId {
	
	NSString* urlString = [NSString stringWithFormat:@"%@/%@%@", ENTITIES_URL, entityId, ALARMS_URL];
	ASIHTTPRequest *request = [NetworkUtils getConnection:urlString
											withAuthToken:authToken 
											 withEndPoint:endPoint];
	
	if(!request) {
		[CloudManagerUtils CMLog:@"Failed to get request object."];
		return nil;
	}
	
	[request startSynchronous];
	NSError *error = [request error];
	
	NSMutableArray* alarms = [[[NSMutableArray alloc] init] autorelease];
	
	if (error) {
		[CloudManagerUtils CMLog:@"Request %@", [request responseString]];
		[CloudManagerUtils CMLog:@"Error %@", error];
		return nil;
	}
	
	int statusCode = [request responseStatusCode];
	[CloudManagerUtils CMLog:@"Response Headers: %@", [request responseHeaders]];
	[CloudManagerUtils CMLog:@"Status Code: %i", statusCode];
	
	if(!(statusCode == 200 || statusCode == 203))
		return nil;
	
	// Use when fetching binary data
	NSData *responseData = [request responseData];
	NSString *strData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	
	[CloudManagerUtils CMLog:@"Data: %s", [strData UTF8String]];
	
	//parse the xml
	NSXMLDocument* doc = [[NSXMLDocument alloc] initWithData:responseData options:0 error:nil];
	
	NSXMLElement* root  = [doc rootElement];
	
	NSArray* checkArray = [root nodesForXPath:@"//alarm" error:nil];
	for(NSXMLElement* xmlElement in checkArray) {
		
		MonAlarm *alarm  = [self parseMonAlarmElement:xmlElement];
		[alarm setEntityId:entityId];		
		[alarms	addObject:alarm];
	}
	
	[doc release];
	[strData release];
	
	return alarms;
}

-(void) deleteAlarm: (NSString*) key withEntityId: (NSString*) entityId {
	
	if([key length] < 1) {
		return;
	}
	
	NSString* urlString = [NSString stringWithFormat:@"%@/%@%@/%@", ENTITIES_URL, entityId, ALARMS_URL, key];
	
	ASIHTTPRequest *request = [NetworkUtils getConnection:urlString
											withAuthToken:authToken 
											 withEndPoint:endPoint];
	
	[request setRequestMethod:@"DELETE"];
	
	[CloudManagerUtils CMLog:@"Request Headers: %@", [request requestHeaders]];
	
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestDone:)];
	[request setDidFailSelector:@selector(requestFailed:)];
	[request startAsynchronous];
	
}

-(NSArray*) getOverviews {
	
	NSString* urlString = OVERVIEW_URL;
	ASIHTTPRequest *request = [NetworkUtils getConnection:urlString
											withAuthToken:authToken 
											 withEndPoint:endPoint];
	
	if(!request) {
		[CloudManagerUtils CMLog:@"Failed to get request object."];
		return nil;
	}
	
	[request startSynchronous];
	NSError *error = [request error];
	
	NSMutableArray* overviews = [[[NSMutableArray alloc] init] autorelease];
	
	if (error) {
		[CloudManagerUtils CMLog:@"Request %@", [request responseString]];
		[CloudManagerUtils CMLog:@"Error %@", error];
		return nil;
	}
	
	int statusCode = [request responseStatusCode];
	[CloudManagerUtils CMLog:@"Response Headers: %@", [request responseHeaders]];
	[CloudManagerUtils CMLog:@"Status Code: %i", statusCode];
	
	if(!(statusCode == 200 || statusCode == 203))
		return nil;
	
	// Use when fetching binary data
	NSData *responseData = [request responseData];
	NSString *strData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	
	[CloudManagerUtils CMLog:@"Data: %s", [strData UTF8String]];
	
	//parse the xml
	NSXMLDocument* doc = [[NSXMLDocument alloc] initWithData:responseData options:0 error:nil];
	
	NSXMLElement* root  = [doc rootElement];
	
	NSArray* overviewArray = [root nodesForXPath:@"//overview" error:nil];
	for(NSXMLElement* xmlElement in overviewArray) {
		MonOverview *overview = [[MonOverview alloc] init];
				
		//entity
		NSArray *entities = [xmlElement nodesForXPath:@"entity" error:nil];
		MonEntity *entity;
		for(NSXMLElement *entityElement in entities) {
			entity = [self parseMonEntityElement: entityElement];
			[overview setEntity:entity];
		}
		
		//checks
		NSArray *checks = [xmlElement nodesForXPath:@"checks/check" error:nil];
		for(NSXMLElement *checkElement in checks) {
			MonCheck *check = [self parseMonCheckElement: checkElement];
			[check setEntityId:entity.key];
			[overview addCheck:check];
		}
		
		//alarms
		NSArray *alarms = [xmlElement nodesForXPath:@"alarms/alarm" error:nil];
		for(NSXMLElement *alarmElement in alarms) {
			MonAlarm *alarm = [self parseMonAlarmElement: alarmElement];
			[alarm setEntityId:entity.key];
			[overview addAlarm:alarm];
		}
		
		//alarm states
		NSArray *alarmStates = [xmlElement nodesForXPath:@"latest_alarm_states/latest_alarm_state" error:nil];
		for(NSXMLElement *alarmStateElement in alarmStates) {
			MonAlarmState *alarmState = [[MonAlarmState alloc] init];
			
			//timestamp
			NSArray *timestamps = [alarmStateElement nodesForXPath:@"timestamp" error:nil];
			NSString *timestamp;
			@try {
				timestamp = [[timestamps objectAtIndex:0] stringValue];
			}
			@catch (NSException * e) {
				timestamp = @"";
			}
			@finally {
				[alarmState setTimestamp:timestamp];
			}
			
			//entity id
			NSArray *entityIds = [alarmStateElement nodesForXPath:@"entity_id" error:nil];
			NSString *entityId;
			@try {
				entityId = [[entityIds objectAtIndex:0] stringValue];
			}
			@catch (NSException * e) {
				entityId = @"";
			}
			@finally {
				[alarmState setEntityId:entityId];
			}
			
			//alarm id
			NSArray *alarmIds = [alarmStateElement nodesForXPath:@"alarm_id" error:nil];
			NSString *alarmId;
			@try {
				alarmId = [[alarmIds objectAtIndex:0] stringValue];
			}
			@catch (NSException * e) {
				alarmId = @"";
			}
			@finally {
				[alarmState setAlarmId:alarmId];
			}
				
			//check id
			NSArray *checkIds = [alarmStateElement nodesForXPath:@"check_id" error:nil];
			NSString *checkId;
			@try {
				checkId = [[checkIds objectAtIndex:0] stringValue];
			}
			@catch (NSException * e) {
				checkId = @"";
			}
			@finally {
				[alarmState setCheckId:checkId];
			}
				
			//state
			NSArray *states = [alarmStateElement nodesForXPath:@"state" error:nil];
			NSString *state;
			@try {
				state = [[states objectAtIndex:0] stringValue];
			}
			@catch (NSException * e) {
				state = @"";
			}
			@finally {
				[alarmState setState:state];
			}
			
			//mon zone
			NSArray *monZones = [alarmStateElement nodesForXPath:@"analyzed_by_monitoring_zone_id" error:nil];
			NSString *monZone;
			@try {
				monZone = [[monZones objectAtIndex:0] stringValue];
			}
			@catch (NSException * e) {
				monZone = @"";
			}
			@finally {
				[alarmState setMonZoneId:monZone];
			}
			
			[overview addAlarmState:alarmState];
			[alarmState release];
		}
		
		[overviews addObject:overview];
		[overview release];
	}
	
	[doc release];
	[strData release];
	
	return overviews;

}

-(void) dealloc {

    [endPoint release];
    [super dealloc];
    
}

@end
