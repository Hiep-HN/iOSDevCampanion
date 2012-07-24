//  SettingsViewController.h
// Copyright 2012 Michael Hourigan. All rights reserved.
// Now under GNU open source license.

#import <UIKit/UIKit.h>

#define kSpeedSettingKey			@"speed"
#define kDensitySettingKey			@"density"

enum { kSpeedSlider, kDensitySlider, kActionList, kDisplayList };		// Items in settings list view. A way to identify the slider or settings options so we know where to store its value when it changes.

typedef enum { kGoogleHotTrends, kGoogleSearch, kFeelingLucky } Action;

@interface SettingsViewController: UITableViewController
{
	float speed;
	float density;
}

@property (assign) float speed;
@property (assign) float density;

@end

SettingsViewController *settings;			// Have an easy-access global for settings.