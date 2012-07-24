// Trend.m - The model class that stores the information about a trend.
// Copyright 2012 Michael Hourigan. All rights reserved.
// Now under GNU open source license.

#import "Trend.h"

@implementation Trend

@synthesize title, webLink, hotness, previousRank;



- (id) init
{
	if ((self = [super init]))
    {
        title = @"";
        webLink = @"";
        hotness = hotness = @"Medium";
        previousRank = previousRank = @"new";
    }   
    return self;
}



- (id) initWithCoder: (NSCoder *) coder
{
    self = [[Trend alloc] init];
    if (self != nil)
    {
        title = [coder decodeObjectForKey: @"title"];
        webLink = [coder decodeObjectForKey: @"webLink"];
        hotness = [coder decodeObjectForKey: @"hotness"];
        previousRank = [coder decodeObjectForKey: @"previousRank"];
    }   
    return self;
}



- (void) encodeWithCoder: (NSCoder *) coder
{
    [coder encodeObject: title forKey: @"title"];
    [coder encodeObject: webLink forKey: @"webLink"];
    [coder encodeObject: hotness forKey: @"hotness"];
    [coder encodeObject: previousRank forKey: @"previousRank"];
}



- (void) dealloc
{
    [title release];
    [webLink release];
    [hotness release];
    [previousRank release];
	[super dealloc];
}



- (BOOL) isEqual: (Trend *) anObject
{
	return [title isEqualToString: anObject.title];
}



- (NSComparisonResult) localizedCaseInsensitiveCompare: (Trend *) anotherTrend
{
	return [self.title localizedCaseInsensitiveCompare: anotherTrend.title];
}

@end
