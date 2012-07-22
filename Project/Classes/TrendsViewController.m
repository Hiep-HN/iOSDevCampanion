//  TrendsViewController.m
//  Copyright 2009 Michael Hourigan. All rights reserved.

#import "TrendsView.h"
#import "AppController.h"
#import "TrendsViewController.h"
#import "TrendsListViewController.h"
#import "CloudViewController.h"
#import "Trend.h"
#import "SearchBarController.h"

#define MOVECLOUDSINBACKGROUND	0	// 0 for same as 1.0 release, 1 for experimenting with speed increases.


@implementation TrendsViewController
@synthesize trendsView, clouds, cloudMakerTimer, cloudMoverTimer, toolbar, searchBarController, searchText, navigationController, selectedCloud, cloudsAreMoving, cloudsArePaused, dialogIsDisplayed, timeOfLastMove;


- (id) init
{
	if (self = [super init])
	{
		CGRect rect = [[UIScreen mainScreen] applicationFrame];
		self.view = [[UIView alloc] initWithFrame: rect];
		rect = self.view.bounds;
		rect.size.height -= TOOLBARHEIGHT;
		self.trendsView = [[TrendsView alloc] initWithFrame: rect];
		[self.view addSubview: trendsView];
		[trendsView release];
		
		self.clouds = [[NSMutableArray arrayWithCapacity: settings.density * kNumberOfPagesInScrollView] retain];

		rect.origin.y = rect.size.height;
		rect.size.height = TOOLBARHEIGHT;
		self.toolbar = [[UIToolbar alloc] initWithFrame: rect];
		toolbar.barStyle = UIBarStyleBlackTranslucent;
		[self.view addSubview: toolbar];
		toolbar.hidden = NO /* YES */ ;		// Let's animate it upwards into view at start-up.
		[toolbar release];
		
		UIBarButtonItem *flexibleItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: NULL];
		UIBarButtonItem *newsItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"iOS.png" ofType: nil inDirectory: @"Images"]] style: UIBarButtonItemStylePlain target: self action: @selector (iOSFeed:)];
		UIBarButtonItem *flexibleItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: NULL];
		UIBarButtonItem *peopleItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"People.png" ofType: nil inDirectory: @"Images"]] style: UIBarButtonItemStylePlain target: self action: @selector (peopleFeed:)];
		UIBarButtonItem *flexibleItem3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: NULL];
		UIBarButtonItem *twitterItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Twitter.png" ofType: nil inDirectory: @"Images"]] style: UIBarButtonItemStylePlain target: self action: @selector (twitterFeed:)];
		UIBarButtonItem *flexibleItem4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: NULL];
		UIBarButtonItem *remindersItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Reminders.png" ofType: nil inDirectory: @"Images"]] style: UIBarButtonItemStylePlain target: self action: @selector (remindersFeed:)];
		UIBarButtonItem *flexibleItem5 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: NULL];
		UIBarButtonItem *postItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCompose target: self action: @selector (singly:)];
		UIBarButtonItem *flexibleItem6 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: NULL];
		[toolbar setItems: [NSArray arrayWithObjects: flexibleItem1, newsItem, flexibleItem2, peopleItem, flexibleItem3, twitterItem, flexibleItem4, remindersItem, flexibleItem5, postItem, flexibleItem6, nil]];
		[flexibleItem1 release];
		[newsItem release];
		[flexibleItem2 release];
		[peopleItem release];
		[flexibleItem3 release];
		[twitterItem release];
		[flexibleItem4 release];
		[remindersItem release];
		[flexibleItem5 release];
		[postItem release];
		[flexibleItem6 release];

		self.cloudsAreMoving = YES;
		self.cloudsArePaused = NO;
		self.dialogIsDisplayed = NO;
		self.cloudMakerTimer = [[NSTimer scheduledTimerWithTimeInterval: .25 target: self selector: @selector (sendCloud:) userInfo: nil repeats: YES] retain];
#if MOVECLOUDSINBACKGROUND
		self.cloudMoverTimer = [[NSTimer scheduledTimerWithTimeInterval: kCloudMoverInterval target: self selector: @selector (moveCloudsInBackground:) userInfo: nil repeats: YES] retain];
#else
		self.cloudMoverTimer = [[NSTimer scheduledTimerWithTimeInterval: kCloudMoverInterval target: self selector: @selector (moveClouds:) userInfo: nil repeats: YES] retain];
#endif
	}
	return self;
}



#if MOVECLOUDSINBACKGROUND

- (void) moveCloudsInBackground: (NSTimer *) timer
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[NSThread detachNewThreadSelector: @selector (moveClouds:) toTarget: self withObject: timer];
    [pool release];
}

#endif



- (void) loadView
{
}



- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
	if (navigationController == nil || navigationController.navigationBarHidden)
		return YES;
	return NO;
}


- (void) didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void) dealloc
{
	[navigationController release];
	[clouds release];
	[cloudMakerTimer invalidate];
	[cloudMakerTimer release];
	[cloudMoverTimer invalidate];
	[cloudMoverTimer release];
	[toolbar release];
	[searchBarController release];
	[searchText release];
	[selectedCloud release];
	[super dealloc];
}



- (void) viewWillAppear: (BOOL) animated
{
	self.cloudsAreMoving = YES;
}



- (void) viewDidDisappear: (BOOL) animated
{
	self.cloudsAreMoving = NO;
}



- (void) retainCloud: (NSString *) animationID context: (CloudViewController *) cloud
{
	// [cloud retain];		Cloud was not released or autoreleased after creation, so no need to retain it. We'll get a static analysis error. Oh, well.
}



- (void) releaseCloud: (NSString *) animationID finished: (BOOL) finished context: (CloudViewController *) cloud
{
	[cloud.view removeFromSuperview];
//	[cloud release];						// This will be released when it is removed from self.clouds.
}



int Random (int range)
{
	// Return a random number in a certain range under 100, cycling through them pretty equally.
	// We want the trends to come up at about the same frequency as each other.
	int randomNumbers[kTrendsInList] = { 43, 12,  9, 97, 95, 59, 55, 17, 31, 41, 74,  5, 63, 67, 82, 75,  4,  2, 79, 87,
										 93, 96, 68, 23, 91, 34, 30,  1, 53, 50, 21, 15, 84, 56,  0, 13, 36, 62, 90, 29,
										 81, 98, 89, 27, 61, 48, 92, 58, 33, 60, 83, 19, 80, 66, 94, 54,  8, 51, 26, 71,
										 24, 85, 18, 77, 73, 42, 38, 99, 86, 46, 64, 32, 16, 47, 70, 25, 52, 28, 49, 44,
										 45, 20,  6, 35, 78, 14, 40, 65,  3, 76, 88, 22, 72, 10, 69, 37, 11,  7, 39, 57, };
	static int lastIndex = kTrendsInList - 1;
	do lastIndex = (lastIndex + 1) % kTrendsInList; while (randomNumbers[lastIndex] >= range);
	return randomNumbers[lastIndex];
}



- (int) countVisibleClouds
{
	CGRect windowFrame = CGRectOffset (self.trendsView.frame, self.trendsView.contentSize.width - self.trendsView.frame.size.width, 0);	// Look only in right-most screen in scrollable view, where the trend clouds come from.
	int count = 0;
	for (CloudViewController *cloud in clouds)
		if (CGRectIntersectsRect (windowFrame, cloud.view.frame))
			count++;
	return count;
}



- (void) sendCloud: (NSTimer *) timer
{
//Make this routine be super-fast by:
//1) Creating a random number array from 0..99, then cycle through it whenever we need a random number.
//2) When finding a space for the cloud, eliminate lanes already used, then simply find a random number among the left-over lanes.
//	Lanes can be 5 pixels wide. This allows for fewer than 100 lanes for the height of the screen.
	if (cloudsAreMoving && !cloudsArePaused)
	{
		// See if it's time to float another trend across the screen.
		int numberOfVisibleClouds = [self countVisibleClouds];
		if (numberOfVisibleClouds < settings.density)
		{
#if MOVECLOUDSINBACKGROUND
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#endif
			
			Trend *trend = nil;
			
#if 0	// Temp trend for development, especially when there is no Internet connection.
			AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
			NSArray *trends = nil;
			trend = [[Trend alloc] init];
			trend.title = [NSString stringWithFormat: @"Testing %d", numberOfVisibleClouds];
			trend.webLink = @"http://www.e-lips.com/";
			switch (random () % 5)
			{
				case 0: trend.hotness = @"Volcanic";	break;
				case 1: trend.hotness = @"On_Fire";		break;
				case 2: trend.hotness = @"Spicy";		break;
				case 3: trend.hotness = @"Medium";		break;
				case 4: trend.hotness = @"Mild";		break;
			}
			trend.previousRank = @"new";
#else
			AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
			NSArray *trends = nil;
			if (appDelegate.currentTrends && [appDelegate.currentTrends count] > 0)
				trends = appDelegate.currentTrends;
			else if (appDelegate.previousTrends && [appDelegate.previousTrends count] > 0)
				trends = appDelegate.previousTrends;
			if (trends)
			{
				int tries = 0;
				do
				{
					int index = Random ([trends count] - 1);				//??? Currently 0..98 because of a problem with trend[99] having nil fields, probably from the RSS parsing syage.
					trend = [trends objectAtIndex: index];
#if 0				// If we have an option to hide items we've visited before.
					if (settings.hideVisitedItems)
					{
						if (appDelegate.history == nil)
							appDelegate.history = [[appDelegate readTrendsWithKey: kHistorySettingKey] mutableCopy];
						if ([appDelegate.history containsObject: trend])
							trend = nil;
					}
#endif
					if (trend != nil && searchText != nil)						// If we are currently limited to a search string, we may "disqualify" the trend and set it to nil so we can find another.
						if ([trend.title rangeOfString: searchText].location == NSNotFound)
							trend = nil;
				} while (trend == nil && ++tries < 100);
			}
#endif
			
			if (trend)
			{
#if 0			// Identify previous trends (the unavailability of current trends).
				if (trends == appDelegate.previousTrends)
				{
					if (trend.title == nil)
						NSLog (@"trend.title is nil!");
					trend.title = [@"*" stringByAppendingString: trend.title];
				}
#endif
				CloudViewController *cloud = [[CloudViewController alloc] initWithTrend: trend];
				CGRect frame = cloud.view.frame;
				//frame.origin.x = self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight ? self.trendsView.frame.size.height : self.trendsView.frame.size.width;
				frame.origin.x = self.trendsView.contentSize.width;
				int screenHeight;
				if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
				{
					screenHeight = self.trendsView.frame.size.width;
					if (searchBarController)
						screenHeight -= KEYBOARDHEIGHTLANDSCAPE;
				}
				else
				{
					screenHeight = self.trendsView.frame.size.height;
					if (searchBarController)
						screenHeight -= KEYBOARDHEIGHTPORTRAIT;
				}
				
				BOOL collision = NO;
#if 0
				frame.origin.y = 10 + random () % (screenHeight - 80);		// Put the view in a random spot vertically.
/*
				int lanes = (screenHeight - 80) / 5;		// Lanes are 5 pixels wide.
				for (CloudViewController *otherCloud in clouds)
					if (cloud != otherCloud && otherCloud.view.frame.origin.x + otherCloud.view.frame.size.width > frame.origin.x)
					{
						for (i = otherCloud.view.frame.origin.y / 5; i < otherCloud.view.frame.origin.y + otherCloud.view.frame.size.height + 4; i++)
						
					}
*/
#else
				int tries = 0;
				do
				{
					frame.origin.y = 10 + random () % (screenHeight - 80);		// Put the view in a random spot vertically.
					collision = NO;
					for (CloudViewController *otherCloud in clouds)
						if (cloud != otherCloud && CGRectIntersectsRect (frame, otherCloud.view.frame))
						{
							collision = YES;
							break;
						}
				} while (collision && ++tries < 10);
#endif
				
				if (!collision)
				{
					[clouds addObject: cloud];
					cloud.view.frame = frame;
					[self.trendsView addSubview: cloud.view];
				}
				[cloud.view release];
				[cloud release];
			}	
#if MOVECLOUDSINBACKGROUND
		[pool release];
#endif
		}
	}
}



- (void) moveClouds: (NSTimer *) timer
{
	NSTimeInterval timeSinceLastMove = NOW - self.timeOfLastMove;
	if (cloudsAreMoving && !cloudsArePaused)
	{
		CloudViewController *cloudToRemove = nil;
		for (CloudViewController *cloud in clouds)
			if (cloud != selectedCloud)
			{
				CGRect frame = cloud.view.frame;
				frame.origin.x -= cloud.speed * settings.speed * timeSinceLastMove * 60;
				cloud.view.frame = frame;
				if (frame.origin.x + frame.size.width < 0)
					cloudToRemove = cloud;
			}
		if (cloudToRemove != nil)
		{
			[self releaseCloud: nil finished: YES context: cloudToRemove];
			[clouds removeObject: cloudToRemove];
		}
	}
	self.timeOfLastMove += timeSinceLastMove;
}



- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation duration: (NSTimeInterval) duration
{
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDuration: duration];
	toolbar.alpha = (toInterfaceOrientation == UIInterfaceOrientationPortrait) ? 1.0 : 0.0;
	
	CGSize screenSize = [UIScreen mainScreen].bounds.size;
	switch (toInterfaceOrientation)
	{
		case UIInterfaceOrientationPortrait:			trendsView.frame = CGRectMake (0, 0, screenSize.width, screenSize.height - 20 - TOOLBARHEIGHT);	break;
		case UIInterfaceOrientationPortraitUpsideDown:	trendsView.frame = CGRectMake (0, 0, screenSize.width, screenSize.height - 20);	break;
		case UIInterfaceOrientationLandscapeLeft:		trendsView.frame = CGRectMake (0, 0, screenSize.height, screenSize.width - 20);	break;
		case UIInterfaceOrientationLandscapeRight:		trendsView.frame = CGRectMake (0, 0, screenSize.height, screenSize.width - 20);	break;
	}
	
	[UIView commitAnimations];
	[searchBarController willRotateToInterfaceOrientation: toInterfaceOrientation duration: duration];	// Pass this on to the search bar.
}



- (void) navigationBarGone
{
	navigationController.navigationBarHidden = YES;		// This determines whether the view is rotatable (navigation bar visible means don't rotate).
}



- (void) doneAction: (id) sender
{
	self.cloudsAreMoving = YES;
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDuration: .3];
	CGRect rect = navigationController.view.frame;
	rect.origin.y = self.view.frame.origin.y + self.view.frame.size.height;
	navigationController.view.frame = rect;
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector (navigationBarGone)];
	[UIView commitAnimations];
//	[navigationController.view removeFromSuperview];		//??? We should keep creating and adding this view. Do it once at start-up, then only show it and hide it.
	self.dialogIsDisplayed = NO;
}



- (void) iOSFeed: (id) sender
{
	NSLog (@"> iOSFeed");
	AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
	appDelegate.feed = kBlekkoiOS;
	[appDelegate updateFeed: nil];
}



- (void) peopleFeed: (id) sender
{
	NSLog (@"> peopleFeed");
	AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
	appDelegate.feed = kRavenZachary;
	[appDelegate updateFeed: nil];
}



- (void) twitterFeed: (id) sender
{
	NSLog (@"> twitterFeed");
	AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
	appDelegate.feed = kiOSDevCampOnTwitter;
	[appDelegate updateFeed: nil];
}



- (void) remindersFeed: (id) sender
{
	NSLog (@"> remindersFeed");
	AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
	appDelegate.feed = kReminders;
	[appDelegate updateFeed: nil];
}



- (void) singly: (id) sender
{
	NSLog (@"> singly");
	UIActionSheet *alertView = [[UIActionSheet alloc] initWithTitle: @"I want a helicopter from Singly!"
														   delegate: self
												  cancelButtonTitle: @"Cancel"
											 destructiveButtonTitle: nil
												  otherButtonTitles: @"Plaster Internet with this message", nil];
	[alertView showInView: self.trendsView];
	[alertView release];
}



- (void) tap: (CloudViewController *) cloud
{
	if (cloud)
	{
		((UILabel *) cloud.view).highlighted = YES;
		
		// Animate it zooming in (growing).
		[UIView beginAnimations: nil context: nil];
		[UIView setAnimationDuration: 0.3];
		cloud.view.transform = CGAffineTransformMakeScale (1.3, 1.3);
		[UIView commitAnimations];
		
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString: cloud.trend.webLink]];
	}
}



- (void) hold: (CloudViewController *) cloud
{
	if (cloud && !dialogIsDisplayed)
	{
		self.dialogIsDisplayed = YES;
		self.selectedCloud = cloud;
		[UIView beginAnimations: nil context: nil];
		[UIView setAnimationDuration: 0.3];
		CGRect rect;
		if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
		{
			((UILabel *) selectedCloud.view).font = [UIFont systemFontOfSize: 40];
			((UILabel *) selectedCloud.view).textColor = [UIColor yellowColor];
			
			rect = self.trendsView.frame;
			rect.size.width = 10000;
			rect.origin.y = 0;
			rect.size.height = 40;		// We actually want the top of the menu view.
			((UILabel *) selectedCloud.view).textAlignment = UITextAlignmentLeft;
			((UILabel *) selectedCloud.view).numberOfLines = 1;
			
			rect.origin.y = (40 - rect.size.height) / 2;
			rect.origin.x = 6 + self.trendsView.contentOffset.x;
		}
		else
		{
			((UILabel *) selectedCloud.view).font = [UIFont systemFontOfSize: 48];
			((UILabel *) selectedCloud.view).textColor = [UIColor yellowColor];
			
#if 0		// If we don't include the item in the title of the dialog.
			rect = self.trendsView.frame;
			rect.origin.y = 0;
			rect.size.height = 160;		// We actually want the top of the menu view.
			((UILabel *) selectedCloud.view).textAlignment = UITextAlignmentCenter;
			((UILabel *) selectedCloud.view).numberOfLines = 0;
			rect.size = [((UILabel *) selectedCloud.view).text sizeWithFont: ((UILabel *) selectedCloud.view).font constrainedToSize: rect.size];
			//??? Adjust font size if it results in truncation or awkward line break.
			
			rect.origin.y = (160 - rect.size.height) / 2;
			rect.origin.x = (self.trendsView.frame.size.width - rect.size.width) / 2 + self.trendsView.contentOffset.x;
#else
			((UILabel *) selectedCloud.view).font = [UIFont systemFontOfSize: 40];
			((UILabel *) selectedCloud.view).textColor = [UIColor yellowColor];
			
			rect = self.trendsView.frame;
			float screenWidth = rect.size.width;
			rect.size.width = 10000;
			rect.size.height = 40;		// We actually want the top of the menu view.
			((UILabel *) selectedCloud.view).textAlignment = UITextAlignmentLeft;
			((UILabel *) selectedCloud.view).numberOfLines = 1;
			
			rect.origin.y = (70 - rect.size.height) / 2;
			
			float textWidth = [((UILabel *) selectedCloud.view).text sizeWithFont: ((UILabel *) selectedCloud.view).font constrainedToSize: rect.size].width;
			if (textWidth < screenWidth)
				rect.origin.x = self.trendsView.contentOffset.x + (screenWidth - textWidth) / 2;
			else
				rect.origin.x = 6 + self.trendsView.contentOffset.x;
			rect.size.width = textWidth;
#endif
		}
		cloud.view.frame = rect;
		[UIView commitAnimations];
		
		[self tap: (CloudViewController *) cloud];
	}
}



- (void) scrollWithEvent: (UIEvent *) event
// User dragged right, or held finger down on background.
{
/*
	self.cloudsAreMoving = NO;
	create scroll view UIScrollView
	apply current touch to it if necessary
*/
}



#pragma mark UISearchBarDelegate

- (void) searchBar: (UISearchBar *) searchBar textDidChange: (NSString *) newSearchText
{
	if (newSearchText == nil || [newSearchText length] == 0 || [newSearchText isEqualToString: @"Ok"])	// Don't know why closing search field is sending "Ok" here instead of 
	{
		self.searchText = nil;
	}
	else
	{
		self.searchText = [newSearchText lowercaseString];
		[UIView beginAnimations: nil context: nil];
		[UIView setAnimationDuration: 0.5];
		for (CloudViewController *cloud in clouds)
			cloud.view.alpha = ([cloud.trend.title rangeOfString: searchText].location != NSNotFound) ? 1.0 : 0.0;
		[UIView commitAnimations];
	}
}



- (void) searchBarSearchButtonClicked: (UISearchBar *) searchBar
{
	[self searchBarCancelButtonClicked: searchBar];		// This just makes the search field and keyboard go away.
}



- (void) removeSearchField: (NSString *) animationID finished: (BOOL) finished context: (void *) context
{
	[searchBarController.view resignFirstResponder];
	searchBarController.view.alpha = 0;/// Following crashes when clouds go offscreen:	[searchBarController.view removeFromSuperview];
	self.searchBarController = nil;
	self.searchText = nil;
}



- (void) searchBarCancelButtonClicked: (UISearchBar *) searchBar
{
	[searchBar resignFirstResponder];
	// Hide searchBar by animating it downward.
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDuration: 0.5];
	CGRect frame = searchBar.frame;
	frame.origin.y = self.view.frame.origin.y + self.view.frame.size.height + 10;
	searchBar.frame = frame;
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector (removeSearchField:finished:context:)];
	[UIView commitAnimations];
	self.searchText = nil;
}



#pragma mark UIActionSheetDelegate

- (void) actionSheet: (UIActionSheet *) actionSheet clickedButtonAtIndex: (NSInteger) buttonIndex
{
	self.selectedCloud = nil;
	self.dialogIsDisplayed = NO;
}

@end
