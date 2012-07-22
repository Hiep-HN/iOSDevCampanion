// Trend.h - The model class that stores the information about a trend.

#import <Foundation/Foundation.h>

@interface Trend : NSObject
{
    NSString *title;			// Holds previousRank and hotness.
    NSString *webLink;			// Holds the URL to the Google web page of the hot trend.
	NSString *hotness;			// Volcanic, On_Fire, Spicy, Medium, or Mild.
	NSString *previousRank;		// new, equal, upxx, or downxx where xx is relative previous rank.
	NSString *trendCategory;	// Type of item: kHotTrends, kStockQuotes, kTopNews, etc.
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *webLink;
@property (nonatomic, retain) NSString *hotness;
@property (nonatomic, retain) NSString *previousRank;

@end
