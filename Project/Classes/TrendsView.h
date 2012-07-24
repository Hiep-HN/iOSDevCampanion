// TrendsView.h
// Copyright 2012 Michael Hourigan. All rights reserved.
// Now under GNU open source license.

#import <UIKit/UIKit.h>
#import "ClickableScrollView.h"
#import "CloudViewController.h"

@interface TrendsView: /* UIScrollView */ ClickableScrollView <UIScrollViewDelegate>
{
	UIImageView *backgroundImage;
	NSTimer *holdTimer;
	BOOL dragMode;
	UITouch *firstTouch;				// The touch object of the first finger that touched.
	CGPoint firstLocation;				// The location of the first touch.
	NSTimeInterval timeOfFirstTouch;
	CloudViewController *tappedCloud;
}

@property (nonatomic, retain) UIImageView *backgroundImage;
@property (nonatomic, retain) UITouch *firstTouch;
@property (assign) CGPoint firstLocation;
@property (assign) NSTimeInterval timeOfFirstTouch;
@property (nonatomic, retain) CloudViewController *tappedCloud;
@property (nonatomic, retain) NSTimer *holdTimer;
@property (assign) BOOL dragMode;

@end
