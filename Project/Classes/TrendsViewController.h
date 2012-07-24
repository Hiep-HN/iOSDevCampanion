// TrendsViewController.h
// Copyright 2012 Michael Hourigan. All rights reserved.
// Now under GNU open source license.

#import <UIKit/UIKit.h>
#import "TrendsView.h"
#import "CloudViewController.h"

#define KEYBOARDHEIGHTPORTRAIT		216		// Later we can get this info dynamically using notifications; when the keyboard pops up, the notification includes the size.
#define KEYBOARDHEIGHTLANDSCAPE		162
#define kNumberOfPagesInScrollView	4		// Determines how far the user can scroll. The background picture must be at least this wide.
#define kPlayPauseItem				3
#define kCloudMoverInterval			(1.0 / 30.0)	// Time between updating cloud positions, in seconds.

#define NOW	[NSDate timeIntervalSinceReferenceDate]

@interface TrendsViewController: UIViewController <UIActionSheetDelegate>
{
	TrendsView *trendsView;					// The main view with trends floating by. Doesn't include the toolbar.
	NSMutableArray *clouds;					// List of clouds floating across.
	NSTimer *cloudMakerTimer;				// Periodically see if we should float another trend across the screen.
	NSTimer *cloudMoverTimer;				// Move each cloud a little bit further across the sky.
	UIToolbar *toolbar;						// Toolbar at bottom.
	UINavigationController *navigationController;	// For list of bookmarks that can come up.
	BOOL cloudsAreMoving;
	BOOL cloudsArePaused;
	NSTimeInterval timeOfLastMove;			// Seconds since last animation of clouds. Used to time the velocity.
}

@property (nonatomic, retain) TrendsView *trendsView;
@property (nonatomic, retain) NSMutableArray *clouds;
@property (nonatomic, retain) NSTimer *cloudMakerTimer;
@property (nonatomic, retain) NSTimer *cloudMoverTimer;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (assign) BOOL cloudsAreMoving;
@property (assign) BOOL cloudsArePaused;
@property (assign) NSTimeInterval timeOfLastMove;

- (void) tap: (CloudViewController *) cloud;
- (void) hold: (CloudViewController *) cloud;
- (void) scrollWithEvent: (UIEvent *) event;

@end
