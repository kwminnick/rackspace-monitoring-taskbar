/*
 *  constants.h
 *  obj-c2
 *
 *  Created by Kevin Minnick on 8/10/11.
 *  Copyright 2011 Kevin Minnick. All rights reserved.
 *
 */

#define NO_LOGGING				0
#define NORMAL_LOGGING			3
#define HIGH_LOGGING			5

#define DEBUG_LEVEL				HIGH_LOGGING

#define USER_AGENT				@"objective-c-client-cloudmanager3"

//HTTP Headers
#define CONTENT_TYPE_HEADER		@"application/xml; charset=UTF-8"
#define ACCEPT_HEADER			@"application/xml"

//URLS for Monitoring
#define ENTITIES_URL			@"/entities"
#define CHECKS_URL				@"/checks"
#define MONITORING_ZONES_URL	@"/monitoring_zones"
#define NOTIFICATIONS_URL		@"/notifications"
#define NOTIFICATION_PLANS_URL	@"/notification_plans"
#define ALARMS_URL				@"/alarms"
#define TEST_CHECK_URL			@"/test-check"
#define OVERVIEW_URL			@"/views/overview"

//version strings
#define ONE_POINT_ZERO			@"1.0"
#define ONE_POINT_ONE			@"1.1"
#define TWO_POINT_ZERO			@"2.0"

#define SERVERS_VERSION_TWO     @"/v2"

//types supported
#define RACKSPACE				@"Rackspace"
#define OPENSTACK				@"OpenStack"

//rackspace specific constants (US)
#define RACKSPACE_CLOUD			@"Rackspace Cloud (US)"
#define RACKSPACE_AUTH2_URL		@"https://auth.api.rackspacecloud.com/v2.0"
#define RACKSPACE_MON_URL		@"https://cmbeta.api.rackspacecloud.com/v1.0"

//keychain
#define RAX_MON_TASKBAR         @"Rackspace Cloud Monitoring Taskbar"
#define RAX_MON_TASKBAR_ACCOUNT @"internet password"
