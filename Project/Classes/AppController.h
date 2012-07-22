// AppController.h - Controller for the application.

#import <UIKit/UIKit.h>
#import "TrendsViewController.h"
#import "Trend.h"
#import "SettingsViewController.h"

#define HOLDTIMER				0		// YES if we want to take a "tap" action after user holds down for a period.

#define	TOOLBARHEIGHT			40
#define kMinutesBetweenUpdates	30		// Check for new RSS feed occasionally. They are updated every hour or so. Set to .05 for finding leaks.
#define kTrendsInList			100

#define kBlekkoiOS				@"Blekko iOS"
#define kiOSDevCampOnTwitter	@"iOSDevCamp"
#define kRavenZachary			@"Raven Zachary"
#define kReminders				@"Reminders"

#define COMPONENT(ubyte)					((ubyte) / 255.)			// Allows us to use Color Picker slider values directly.

@interface AppController: UIViewController <UIApplicationDelegate>
{
	UIWindow *window;
	TrendsViewController *trendsViewController;
	
	NSString *feed;
	
	NSMutableArray *currentTrends;
	NSMutableArray *bookmarks;			// Array of bookmarked trends from defaults.
	NSMutableArray *history;			// Array of visited trends from defaults. May hold 10, 25, or 50 of the last trends that were tapped on.
    NSArray *previousTrends;			// Array of last session's currentTrends.
	NSDictionary *feedURLs;				// Dictionary relating name of feed to its URL.
	
    BOOL isDataSourceAvailable;
	NSTimer *updateFeedTimer;			// Occasionally check for update to Google Hot Trends RSS feed.
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) TrendsViewController *trendsViewController;
@property (nonatomic, retain) NSString *feed;
@property (nonatomic, retain) NSMutableArray *currentTrends;
@property (nonatomic, retain) NSMutableArray *bookmarks;
@property (nonatomic, retain) NSMutableArray *history;
@property (nonatomic, retain) NSArray *previousTrends;
@property (nonatomic, retain) NSTimer *updateFeedTimer;

- (BOOL) isDataSourceAvailable;

@end

@interface AppController (AppDelegateMethods)

- (void) showTrendInfo: (Trend *) dictionary  action: (Action) action;
- (void) getTrendData;
- (void) addToTrendList: (Trend *) eq;
- (void) setTrendList: (NSMutableArray *) newTrends;
- (void) updateFeed: (NSTimer *) timer;
- (BOOL) isDataSourceAvailable;
- (void) saveTrends: (NSArray *) trends withKey: (NSString *) key;
- (NSArray *) readTrendsWithKey: (NSString *) key;

@end
