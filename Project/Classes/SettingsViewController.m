//  SettingsViewController.m
//  Copyright 2009 Michael Hourigan. All rights reserved.

#import "SettingsViewController.h"
#import "AppController.h"
#import "SliderCell.h"

@implementation SettingsViewController
@synthesize speed, density;



- (id) initWithStyle: (UITableViewStyle) style
{
	if (self = [super initWithStyle: UITableViewStyleGrouped])
	{
		self.title = NSLocalizedString (@"Settings", @"SettingsViewController title");
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.rowHeight = 48.0;
		UIEdgeInsets inset = self.tableView.contentInset;
		inset.top = 10;
        self.tableView.contentInset = inset;
		self.tableView.scrollEnabled = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		self.speed = 3;//[defaults floatForKey: kSpeedSettingKey];
		self.density = [defaults floatForKey: kDensitySettingKey];
	}
	return self;
}



- (void) dealloc
{
	[super dealloc];
}



- (void) sliderAction: (UISlider *) slider
{
	switch (slider.tag)
	{
		case kSpeedSlider:
			speed = slider.value;
			break;
		case kDensitySlider:
			density = slider.value;
			break;
	}
}



#pragma mark UITableViewDelegate

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
	return 2;
}



- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
	return 1;
}



- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
	UITableViewCell *cell = nil;
    
	cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier: @"SettingsCell"];
	if (cell == nil)
		cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"SettingsCell"] autorelease];
	switch (indexPath.section)
	{
		case 0:
			cell = [[[SliderCell alloc] initWithValue: settings.speed minimum: .3 maximum: 3 minimumImageName: @"Slow.png" maximumImageName: @"Fast.png" target: self tag: kSpeedSlider] autorelease];
			cell.accessoryType = UITableViewCellAccessoryNone;
			break;
		case 1:
			cell = [[[SliderCell alloc] initWithValue: settings.density minimum: 2 maximum: 14 minimumImageName: @"Sparse.png" maximumImageName: @"Dense.png" target: self tag: kDensitySlider] autorelease];
			cell.accessoryType = UITableViewCellAccessoryNone;
			break;
	}
	return cell;
}


- (NSString *) tableView: (UITableView *) tableView titleForHeaderInSection: (NSInteger) section
{
	switch (section)
	{
		case 0:
			return @"Speed";
		case 1:
			return @"Density";
	}
	return nil;
}

@end

