// AppController.m - Controller for the application.

#import "AppController.h"
#import "TrendsListViewController.h"
#import "XMLReader.h"
#import "Trend.h"
#import "TrendsViewController.h"
#import "CloudViewController.h"
#import "SettingsViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>

@implementation AppController
@synthesize window, trendsViewController, feed, currentTrends, bookmarks, history, previousTrends, updateFeedTimer;



- init
{
	if (self = [super init])
	{
		feedURLs = [[NSDictionary dictionaryWithObjectsAndKeys:
			@"http://blekko.com/?q=ios+/topnews+/tech+/date+/rss&auth=77e8c1ba",	kBlekkoiOS,
			@"http://search.twitter.com/search.rss?q=iosdevcamp",	kiOSDevCampOnTwitter,
			@"http://blekko.com/?q=%22raven+zachary%22+%22dom+sagolla%22+%22christopher+allen%22+/date+/rss&auth=77e8c1ba",	kRavenZachary,
			@"",	kReminders,
			nil] retain];
		self.feed = kBlekkoiOS;
		NSMutableDictionary *defaultSettings = [NSMutableDictionary dictionary];
		[defaultSettings setObject: [NSNumber numberWithFloat: 1.0] forKey: kSpeedSettingKey];
		[defaultSettings setObject: [NSNumber numberWithFloat: 7.0] forKey: kDensitySettingKey];
		[[NSUserDefaults standardUserDefaults] registerDefaults: defaultSettings];
		settings = [[SettingsViewController alloc] initWithStyle: UITableViewStyleGrouped];
	}
	return self;
}



- (void) showTrendInfo: (Trend *) trend action: (Action) action
{
    // When the user taps a row in the table, display the Google web page that displays details of the trend they selected.
	if (history == nil)
		self.history = [[self readTrendsWithKey: kHistorySettingKey] mutableCopy];
	[history removeObject: trend];							// In case it is already there, remove it and move it to the top.
	[history insertObject: trend atIndex: 0];
	if ([history count] > kHistorySize)
		[history removeObjectsAtIndexes: [NSIndexSet indexSetWithIndexesInRange: NSMakeRange (kHistorySize, [history count] - kHistorySize)]];
	[self saveTrends: history withKey: kHistorySettingKey];
	switch (action)
	{
		case kGoogleHotTrends:
			[[UIApplication sharedApplication] openURL: [NSURL URLWithString: trend.webLink]];
			break;
		case kGoogleSearch:
			[[UIApplication sharedApplication] openURL: [NSURL URLWithString: [NSString stringWithFormat: @"http://www.google.com/search?q=%@&ie=UTF-8&oe=UTF-8&client=safari", [trend.title stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]]];
			break;
		case kFeelingLucky:
			[[UIApplication sharedApplication] openURL: [NSURL URLWithString: [NSString stringWithFormat: @"http://www.google.com/search?q=%@&btnI=I%%27m+Feeling+Lucky", [trend.title stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]]];
			break;
	}
}



// Use the SystemConfiguration framework to determine if the host that provides
// the RSS feed is available.
- (BOOL) isDataSourceAvailable
{
    static BOOL checkNetwork = YES;
    if (checkNetwork)			// Since checking the reachability of a host can be expensive, cache the result and perform the reachability check once.
	{
        checkNetwork = NO;
        
        Boolean success;    

        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName (NULL, "www.google.com");
        SCNetworkReachabilityFlags flags;
        success = SCNetworkReachabilityGetFlags(reachability, &flags);
        isDataSourceAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
    }
    return isDataSourceAvailable;
}



- (void) updateFeed: (NSTimer *) timer
{
#if 1	// Real way: in background.
NSLog (@"> updateFeed");
   [NSThread detachNewThreadSelector: @selector (getTrendData) toTarget: self withObject: nil];
#else
	[self getTrendData];
#endif
}



- (void) getTrendData
{
	NSLog (@"> getTrendData");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSError *parseError = nil;

	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	if ([feed isEqualToString: kReminders])
	{
		NSMutableArray *trends = [NSMutableArray arrayWithCapacity: 5];
		Trend *trend;
		
		trend = [[Trend alloc] init];
		trend.title = @"Eat";
		trend.webLink = @"";
		trend.hotness = @"Medium";
		trend.previousRank = @"new";
		[trends addObject: trend];
		[trend release];
		
		trend = [[Trend alloc] init];
		trend.title = @"Drink";
		trend.webLink = @"";
		trend.hotness = @"Medium";
		trend.previousRank = @"new";
		[trends addObject: trend];
		[trend release];
		
		trend = [[Trend alloc] init];
		trend.title = @"Sleep";
		trend.webLink = @"";
		trend.hotness = @"Medium";
		trend.previousRank = @"new";
		[trends addObject: trend];
		[trend release];
		
		trend = [[Trend alloc] init];
		trend.title = @"Go to the bathroom";
		trend.webLink = @"";
		trend.hotness = @"Medium";
		trend.previousRank = @"new";
		[trends addObject: trend];
		[trend release];
		
		trend = [[Trend alloc] init];
		trend.title = @"Stretch";
		trend.webLink = @"";
		trend.hotness = @"Medium";
		trend.previousRank = @"new";
		[trends addObject: trend];
		[trend release];
		
		[self setTrendList: trends];
	}
	else
	{
		XMLReader *streamingParser = [[XMLReader alloc] init];
		[streamingParser parseXMLFileAtURL: [NSURL URLWithString: [feedURLs objectForKey: feed]] parseError: &parseError];
		[streamingParser release];
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[pool release];
}



- (void) setTrendList: (NSMutableArray *) newTrends
{
	NSLog (@"> setTrendList");
    self.currentTrends = newTrends;
	[self updateFeed: nil];		// Spawn a thread to fetch the trend data so that the UI is not blocked while the application parses the XML file.
}



- (void) applicationDidFinishLaunching: (UIApplication *) application
{
	settings = [[SettingsViewController alloc] init];
    self.currentTrends = nil;
	self.previousTrends = [self readTrendsWithKey: kPreviousTrendsSettingKey];
	self.bookmarks = [[[self readTrendsWithKey: kBookmarksSettingKey] mutableCopy] retain];

	CGRect rect = [[UIScreen mainScreen] bounds];
	
	//Create a full-screen window
	self.window = [[UIWindow alloc] initWithFrame: rect];
	[window makeKeyAndVisible];
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque];
	
	self.trendsViewController = [[TrendsViewController alloc] init];
	[window addSubview: self.trendsViewController.view];				// I don't understand why this works, since loadView hasn't been called yet.

    if ([self isDataSourceAvailable] == NO)
        return;
    
	[self updateFeed: nil];		// Spawn a thread to fetch the trend data so that the UI is not blocked while the application parses the XML file.
	self.updateFeedTimer = [NSTimer scheduledTimerWithTimeInterval: 60 * kMinutesBetweenUpdates target: self selector: @selector (updateFeed:) userInfo: nil repeats: YES];
}



- (void) applicationWillTerminate: (UIApplication *) application
{
	NSUserDefaults *defaultSettings = [NSUserDefaults standardUserDefaults];
	[defaultSettings setObject: [NSNumber numberWithFloat: settings.speed] forKey: kSpeedSettingKey];
	[defaultSettings setObject: [NSNumber numberWithFloat: settings.density] forKey: kDensitySettingKey];
	[defaultSettings synchronize];
	if ([currentTrends count] > 0)
		[self saveTrends: currentTrends withKey: kPreviousTrendsSettingKey];
}



- (void) dealloc
{
	[trendsViewController release];
	[window release];
	[currentTrends release];
	[bookmarks release];
	[history release];
	[previousTrends release];
	[settings release];
	[updateFeedTimer invalidate];
	[updateFeedTimer release];
	[super dealloc];
}



- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
	return YES;
}



- (void) saveTrends: (NSArray *) trends withKey: (NSString *) key
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray *trendsArray = [NSMutableArray arrayWithCapacity: [trends count]];
	for (Trend *trend in trends)
	{
		NSDictionary *trendDictionary = [NSDictionary dictionaryWithObjectsAndKeys: trend.title, @"title", trend.webLink, @"webLink", trend.hotness, @"hotness", trend.previousRank, @"previousRank", nil];
		[trendsArray addObject: trendDictionary];
	}
	[defaults setObject: trendsArray forKey: key];
	[defaults synchronize];
}



- (NSArray *) readTrendsWithKey: (NSString *) key
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray *trends = nil;
	NSArray *trendsArray = [defaults arrayForKey: key];
	if (trendsArray)
	{
		trends = [NSMutableArray arrayWithCapacity: kTrendsInList];
		for (NSDictionary *trendDictionary in trendsArray)
		{
			Trend *trend = [[Trend alloc] init];
			trend.title = [[trendDictionary objectForKey: @"title"] retain];
			trend.webLink = [[trendDictionary objectForKey: @"webLink"] retain];
			trend.hotness = [[trendDictionary objectForKey: @"hotness"] retain];
			trend.previousRank = [[trendDictionary objectForKey: @"previousRank"] retain];
			[trends addObject: trend];
			[trend release];
		}
	}
	return trends;
}

@end
