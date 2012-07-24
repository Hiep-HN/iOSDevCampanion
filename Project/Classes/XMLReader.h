// XMLReader.h - Uses NSXMLParser to extract the contents of an XML file and map it Objective-C model objects.
// Copyright 2012 Michael Hourigan. All rights reserved.
// Now under GNU open source license.

#import <Foundation/Foundation.h>
#import "Trend.h"
#import "AppController.h"			// Defines kMaxTrends.

@interface XMLReader: NSObject <NSXMLParserDelegate>
{
    Trend *currentTrendObject;
	NSMutableArray *trends;
    NSString *contentOfCurrentTrendProperty;
	NSUInteger parsedTrendsCounter;
	BOOL parseCDATA;
}

@property (nonatomic, retain) Trend *currentTrendObject;
@property (nonatomic, retain) NSMutableArray *trends;
@property (nonatomic, retain) NSString *contentOfCurrentTrendProperty;
@property (assign) NSUInteger parsedTrendsCounter;
@property (assign) BOOL parseCDATA;

- (BOOL) parseXMLFileAtURL: (NSURL *) URL parseError: (NSError **) error;

@end
