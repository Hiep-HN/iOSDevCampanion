//  SearchBarController.m
//  Copyright 2009 Michael Hourigan. All rights reserved.

#import "SearchBarController.h"
#import "AppController.h"

@implementation SearchBarController



- initWithDelegate: (id) viewDelegate
{
	if (self = [self init])
	{
		AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
		CGRect rect = appDelegate.window.frame;
		rect.origin.y = rect.origin.y + rect.size.height + 10;
		rect.size.height = 20;
		UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame: rect];	// Will be added to a view by the caller, which will increment the retain count.
		searchBar.delegate = viewDelegate;
		searchBar.barStyle = UIBarStyleBlackTranslucent;
		searchBar.autocorrectionType = NO;
		searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
		searchBar.placeholder = @" Limit items to this text";
		searchBar.showsCancelButton = NO;
		for (UITextField *searchField in searchBar.subviews)
			if ([searchField isKindOfClass: [UITextField class]])
			{
				searchField.returnKeyType = UIReturnKeyDone;		// The Return key will actually be a Done key.
				searchField.enablesReturnKeyAutomatically = NO;		// We want the Done key anebled all the time.
			}
		[searchBar becomeFirstResponder];
		searchBar.tintColor = [UIColor colorWithRed: COMPONENT (50) green: COMPONENT (50) blue: COMPONENT (50) alpha: 1.0];
		self.view = searchBar;
		[appDelegate.window addSubview: searchBar];
		[searchBar release];
		
		[UIView beginAnimations: nil context: nil];
		[UIView setAnimationDuration: 0.5];
		rect = appDelegate.window.frame;
		rect.origin.y = rect.size.height - KEYBOARDHEIGHTPORTRAIT - 24;
		rect.size.height = 20;
		searchBar.frame = rect;
		[UIView commitAnimations];
	}
	return self;
}



- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
	return YES;
}



- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation duration: (NSTimeInterval) duration
{
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDuration: duration];
	self.view.transform = CGAffineTransformMakeRotation (0);
	switch (toInterfaceOrientation)
	{
		case UIInterfaceOrientationPortrait:
			self.view.frame = CGRectMake (0, 456 - KEYBOARDHEIGHTPORTRAIT, 320, 20);	// Trial-and-error hard-coded numbers.
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			self.view.frame = CGRectMake (0, 436 - KEYBOARDHEIGHTPORTRAIT, 320, 20);	// Trial-and-error hard-coded numbers.
			self.view.transform = CGAffineTransformMakeRotation (-2 * 1.57079633);		// Same as 2 * 1.57... but rotates the correct way.
			break;
		case UIInterfaceOrientationLandscapeLeft:
			self.view.frame = CGRectMake (-96, 230, 480, 20);							// Trial-and-error hard-coded numbers.
			self.view.transform = CGAffineTransformMakeRotation (-1.57079633);
			break;
		case UIInterfaceOrientationLandscapeRight:
			self.view.frame = CGRectMake (-64, 228, 480, 20);							// Trial-and-error hard-coded numbers.
			self.view.transform = CGAffineTransformMakeRotation (1.57079633);
			break;
	}
	[UIView commitAnimations];
}



- (void) didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}



- (void) dealloc
{
	[super dealloc];
}

@end
