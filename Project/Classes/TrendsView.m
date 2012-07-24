// TrendsView.m
// Copyright 2012 Michael Hourigan. All rights reserved.
// Now under GNU open source license.

#import "TrendsView.h"
#import "TrendsViewController.h"
#import "AppController.h"

@implementation TrendsView
@synthesize backgroundImage, firstTouch, firstLocation, timeOfFirstTouch, tappedCloud, holdTimer, dragMode;



- (void) wrapAround: (NSString *) animationID finished: (BOOL) finished context: (UIImageView *) background
{
	static int id = 0;							// We want a different animationID for the next wrap, or else the animation will get confused.
	id++;
	CGRect frame = background.frame;
	frame.origin.x = 0;
	background.frame = frame;

	[UIView beginAnimations: [[NSNumber numberWithInt: id] stringValue] context: background];
	[UIView setAnimationDuration: 40.0];
	frame.origin.x = -background.frame.size.width / 2;
	background.frame = frame;
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector (wrapAround:finished:context:)];
	[UIView commitAnimations];
}



- (id) initWithFrame: (CGRect) proposedFrame
{
	if (self = [super initWithFrame: proposedFrame])
	{
		self.showsVerticalScrollIndicator = NO;
		self.scrollsToTop = NO;					// Maybe we can change this to scroll to the right using [delegate scrollViewWillScrollToTop].
		self.canCancelContentTouches = YES;
		self.delegate = self;
		
		AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
#if 0		// 1 if we want a flat color, 0 if we want a moving background picture. This didn't affect smoothness of scrolling.
		self.backgroundColor = [UIColor colorWithRed: COMPONENT (53) green: COMPONENT (178) blue: COMPONENT (143) alpha: 1.0];
#else
		// If the RSS feed isn't accessible (which could happen if the network isn't available) , show an informative message.
		UIImage *image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Background.png" ofType: nil inDirectory: @"Images"]];
		backgroundImage = [[UIImageView alloc] initWithImage: image];
		[self addSubview: backgroundImage];
		[backgroundImage release];
		[self wrapAround: nil finished: NO context: backgroundImage];		// Start the background moving.
		CGSize viewSize = CGSizeMake (image.size.width / 2, self.frame.size.height);
		self.contentSize = viewSize;
		self.contentOffset = CGPointMake (viewSize.width - self.frame.size.width, 0);
#endif

		if ([appDelegate isDataSourceAvailable] == NO)
			[[[[UIAlertView alloc] initWithTitle: @"Internet is not available" message: nil delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil] autorelease] show];
	}
	return self;
}



- (void) drawRect: (CGRect) rect
{
	// Drawing code
}



- (void) dealloc
{
	[tappedCloud release];
	[backgroundImage release];
	[firstTouch release];
	[holdTimer invalidate];
	[holdTimer release];
	[super dealloc];
}



- (CloudViewController *) tappedCloud: (CGPoint) location
{
	location.x += self.contentOffset.x;
	location.y += self.contentOffset.y;
	AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
	for (CloudViewController *cloud in appDelegate.trendsViewController.clouds)
		if (CGRectContainsPoint (cloud.view.frame, location))		// Bring up menu for adding a bookmark, opening a treend, or cancel.
			return cloud;
	return nil;
}



#pragma mark Events

- (void) touchWasHeld: (NSTimer *) timer
{
	if (ABS ([firstTouch locationInView: self.superview].x - self.firstLocation.x) < 20)		// Forget it if it was dragged horizontally a bit.
	{
		self.dragMode = YES;
		AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
		[appDelegate.trendsViewController hold: tappedCloud];
	}
}



- (void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event
{
	[super touchesBegan: touches withEvent: event];
	self.firstTouch = [touches anyObject];
	self.firstLocation = [firstTouch locationInView: self.superview];
	self.timeOfFirstTouch = [NSDate timeIntervalSinceReferenceDate];
	self.tappedCloud = [self tappedCloud: self.firstLocation];
	self.dragMode = NO;												// The "hold" timer will set this to YES to ignore subsequent touch events.
#if HOLDTIMER
	self.holdTimer = [[NSTimer scheduledTimerWithTimeInterval: .6 target: self selector: @selector (touchWasHeld:) userInfo: nil repeats: NO] retain];
#endif
}



- (void) touchesMoved: (NSSet *) touches withEvent: (UIEvent *) event
{  
	[super touchesMoved: touches withEvent: event];
}



- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event
{
#if HOLDTIMER
	if (!dragMode)
#else
	if (!dragMode && [NSDate timeIntervalSinceReferenceDate] - self.timeOfFirstTouch < .6 && ABS ([firstTouch locationInView: self.superview].x - self.firstLocation.x) < 20)
#endif
	{
		[holdTimer invalidate];
#if 0	// Old way: tap to open.
		AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
		[appDelegate.trendsViewController tap: tappedCloud];
#else	// New way: tap to bring up dialog.
		[self touchWasHeld: nil];
#endif
	}
	[super touchesEnded: touches withEvent: event];
}



- (void) touchesCancelled: (NSSet *) touches withEvent: (UIEvent *) event
{
	[super touchesCancelled: touches withEvent: event];
	[holdTimer invalidate];
}

@end
