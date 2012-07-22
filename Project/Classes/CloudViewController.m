//  CloudViewController.m
//  Copyright 2009 Michael Hourigan. All rights reserved.

#import "CloudViewController.h"
#import "AppController.h"			// Has definition of settings.

@implementation CloudViewController
@synthesize trend, speed;


- (float) fontSize
{
	if ([trend.hotness isEqualToString: @"Volcanic"])
		return 44;
	if ([trend.hotness isEqualToString: @"On_Fire"])
		return 38;
	if ([trend.hotness isEqualToString: @"Spicy"])
		return 32;
	if ([trend.hotness isEqualToString: @"Medium"])
		return 26;
	return 20;
}



- (UIColor *) color
{
#define LIGHTEN(low,high,distance)		MIN (COMPONENT (high), COMPONENT (low) + (COMPONENT (high) - COMPONENT (low)) * distance / 30)
	
	NSUInteger digitsLocation = [trend.previousRank rangeOfCharacterFromSet: [NSCharacterSet decimalDigitCharacterSet]].location;
	NSString *status = trend.previousRank;		// One of up, down, equal, or new.
	int distanceChanged = 0;					// If status is up or down, this holds the difference since the last RSS feed. Could be over 100.
	if (digitsLocation != NSNotFound)
	{
		status = [trend.previousRank substringToIndex: digitsLocation];					// One of up, down, equal, or new.
		distanceChanged = [[trend.previousRank substringFromIndex: digitsLocation] intValue];	// If status is up or down, this holds the difference since the last RSS feed. Could be over 100.
	}
	
	if ([status isEqualToString: @"new"])
		return [UIColor colorWithRed: COMPONENT (206) green: COMPONENT (255) blue: COMPONENT (241) alpha: 1.0];
	if ([status isEqualToString: @"equal"])
		return [UIColor colorWithRed: COMPONENT (61) green: COMPONENT (206) blue: COMPONENT (169) alpha: 1.0];
	if ([status isEqualToString: @"up"])
		return [UIColor colorWithRed: LIGHTEN (88, 228, distanceChanged) green: LIGHTEN (222, 255, distanceChanged) blue: LIGHTEN (187, 249, distanceChanged) alpha: 1.0];
	if ([status isEqualToString: @"down"])
		return [UIColor colorWithRed: LIGHTEN (17, 32, distanceChanged) green: LIGHTEN (25, 90, distanceChanged) blue: LIGHTEN (60, 144, distanceChanged) alpha: 1.0];
	return [UIColor colorWithRed: COMPONENT (83) green: COMPONENT (122) blue: COMPONENT (151) alpha: 1.0];
}



- (float) trendSpeed
{
	float generalSpeed = .8;
	if ([trend.hotness isEqualToString: @"Volcanic"])
		generalSpeed = .48;
	if ([trend.hotness isEqualToString: @"On_Fire"])
		generalSpeed = .56;
	if ([trend.hotness isEqualToString: @"Spicy"])
		generalSpeed = .64;
	if ([trend.hotness isEqualToString: @"Medium"])
		generalSpeed = .72;
	return generalSpeed - .1 + (random () % 20) / 100.;	// Add a little randomness to the speed.
}



- (NSString *) removeSourceName: (NSString *) title
// Some news items can have "<headline> - <news source>". Remove the news source, if any.
// In the future, we may want the source in a small, all-caps font.
{
	return [[title componentsSeparatedByString: @" - "] objectAtIndex: 0];
}



- (id) initWithTrend: (Trend *) trendToFloat
{
	if (self = [self init])
	{
		self.trend = [trendToFloat retain];
		self.speed = [self trendSpeed];
		CGRect rect = CGRectMake (220, 100, 480, 140);
		UILabel *cloudView = [[UILabel alloc] initWithFrame: rect];			//??? track retain count to make sure we release it correctly. //??? Maybe change this to NSTextFieldCell for speed.
		self.view = cloudView;
		cloudView.userInteractionEnabled = YES;
#if 0	// For devlopment, display info about the trend in place of the title.
		cloudView.text = [NSString stringWithFormat: @"%@ %@", trend.hotness, trend.previousRank];
#else
		cloudView.text = [self removeSourceName: trend.title];
#if 0	// If we have an option to mark or parenthesize visited items.
		if (settings.markVisitedItems)
		{
			AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
			if (appDelegate.history == nil)
				appDelegate.history = [[appDelegate readTrendsWithKey: kHistorySettingKey] mutableCopy];
			if ([appDelegate.history containsObject: trend])
				cloudView.text = [NSString stringWithFormat: @"(%@)", cloudView.text];
		}
#endif
#endif
		cloudView.backgroundColor = [UIColor clearColor];
		cloudView.font = [UIFont systemFontOfSize: [self fontSize]];
		cloudView.textColor = [self color];
		cloudView.numberOfLines = 1;
		cloudView.highlightedTextColor = [UIColor yellowColor];
		cloudView.shadowOffset = CGSizeMake (0, 3);
		cloudView.shadowColor = [UIColor colorWithRed: COMPONENT (77) green: COMPONENT (154) blue: COMPONENT (138) alpha: .5];
		rect = cloudView.frame;
		rect.size = [cloudView.text sizeWithFont: cloudView.font];		// Set frame width to width of text.
		cloudView.frame = rect;
	}
	return self;
}



- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
	return YES;
}



- (void) didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}



- (void) dealloc
{
	[trend release];
	[super dealloc];
}

@end
