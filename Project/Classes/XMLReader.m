// XMLReader.m - Uses NSXMLParser to extract the contents of an XML file and map it Objective-C model objects.

#import "XMLReader.h"

@implementation XMLReader
@synthesize currentTrendObject, contentOfCurrentTrendProperty, trends, parsedTrendsCounter, parseCDATA;



- (void) dealloc
{
    [currentTrendObject release];
    [trends release];
    [contentOfCurrentTrendProperty release];
	[super dealloc];
}



- (void) parserDidStartDocument: (NSXMLParser *) parser
{
    self.parsedTrendsCounter = 0;
}



- (BOOL) parseXMLFileAtURL: (NSURL *) URL parseError: (NSError **) error
{
#if 1	// Write the RSS feed to a file for debugging.
    NSData *data = [[NSData alloc] initWithContentsOfURL: URL];
	[data writeToFile: @"RSS Feed" atomically: NO];
	[data release];
#endif
	
	self.parseCDATA = NO;
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL: URL];
    
    [parser setDelegate: self];					// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.

    [parser setShouldProcessNamespaces: NO];
    [parser setShouldReportNamespacePrefixes: NO];
    [parser setShouldResolveExternalEntities: NO];
    self.trends = [NSMutableArray arrayWithCapacity: kTrendsInList];
    
    [parser parse];
    
	NSError *parseError = [parser parserError];
	if (parseError)
		NSLog (@"Parse error: %@", parseError);
    if (parseError && error)
        *error = parseError;
    
    [parser release];
	
	return parseError == nil;
}



- (void) parser: (NSXMLParser *) parser foundCDATA: (NSData *) CDATABlock
{
}



- (void) parser: (NSXMLParser *) parser didStartElement: (NSString *) elementName namespaceURI: (NSString *) namespaceURI qualifiedName: (NSString *) qName attributes: (NSDictionary *) attributeDict
{
    if (qName)
        elementName = qName;

/*
    // If the number of parsed trends is greater than kTrendsInList, abort the parse.
    // Otherwise the application runs very slowly on the device.
    if (parsedTrendsCounter >= kTrendsInList)
	{
		NSLog (@"%d trends >= kTrendsInList; abortParsing", parsedTrendsCounter);
        [parser abortParsing];
		return;
	}
*/
    
	self.contentOfCurrentTrendProperty = nil;				// Text and attributes will go into here. Default is to ignore it.
    if ([elementName isEqualToString: @"item"])
	{
        self.parsedTrendsCounter = parsedTrendsCounter + 1;
		if (parsedTrendsCounter < kTrendsInList)
		{
			self.currentTrendObject = [[Trend alloc] init];		 // An <item> entry in the RSS feed represents a trend, so create an instance of it.
			[trends addObject: currentTrendObject];
			[self.currentTrendObject release];
		}
        self.contentOfCurrentTrendProperty = @"";
    }
	else if ([elementName isEqualToString: @"title"])
	{
        self.contentOfCurrentTrendProperty = @"";
    }
	else if ([elementName isEqualToString: @"link"])
	{
        self.contentOfCurrentTrendProperty = @"";
    }
}



- (void) parser: (NSXMLParser *) parser didEndElement: (NSString *) elementName namespaceURI: (NSString *) namespaceURI qualifiedName: (NSString *) qName
{     
    if (qName)
        elementName = qName;
    if ([elementName isEqualToString: @"title"])
        self.currentTrendObject.title = self.contentOfCurrentTrendProperty;
    else if ([elementName isEqualToString: @"link"])
        self.currentTrendObject.webLink = self.contentOfCurrentTrendProperty;
    else if ([elementName isEqualToString: @"rss"])
		[(id) [[UIApplication sharedApplication] delegate] performSelectorOnMainThread: @selector (setTrendList:) withObject: self.trends waitUntilDone: YES];
    else if ([elementName isEqualToString: @"item"])		// Most common request on Google News seems to be to not include Fox "News", so just omit that source.
		if ([currentTrendObject.title rangeOfString: @"FOXNews" options: NSCaseInsensitiveSearch].location != NSNotFound)
			[trends removeObject: currentTrendObject];
}



- (void) parser: (NSXMLParser *) parser foundCharacters: (NSString *) string
{
    if (self.contentOfCurrentTrendProperty)			// If the current element is one whose content we care about, append 'string' to the property that holds the content of the current element.
		self.contentOfCurrentTrendProperty = [contentOfCurrentTrendProperty stringByAppendingString: string];
}

@end
