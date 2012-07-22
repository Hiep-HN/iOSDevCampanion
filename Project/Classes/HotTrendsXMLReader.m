// HotTrendsXMLReader.m - Uses NSXMLParser to extract the contents of an XML file and map it Objective-C model objects.

#import "HotTrendsXMLReader.h"

@implementation HotTrendsXMLReader



- (void) dealloc
{
    [currentTrendObject release];
    [trends release];
    [self.contentOfCurrentTrendProperty release];
	[super dealloc];
}



- (void) parserDidStartDocument: (NSXMLParser *) parser
{
    self.parsedTrendsCounter = 0;
}



- (BOOL) parseXMLFileAtURL: (NSURL *) URL parseError: (NSError **) error
{
#if 0	// Write the RSS feed to a file for debugging.
    NSData *data = [[NSData alloc] initWithContentsOfURL: URL];
	[data writeToFile: @"RSS Feed" atomically: NO];
	[data release];
#endif
	
	self.parseCDATA = NO;
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL: URL];
    
    [parser setDelegate: self];						// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.

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



- (void) parser: (NSXMLParser *) outerParser foundCDATA: (NSData *) CDATABlock
{
	if (parseCDATA)
	{
		// This next block of code shouldn't be necessary, and can probably be optimized.
		// It is here because the NSXMLParser seems to interpret ampersands inside quotes, so we have to escape them.
		// Which means converting NSData -> NSString -> NSData to be fed into NSXMLParser. What a waste.
		NSString *stringData = [[NSString alloc] initWithData: CDATABlock encoding: NSUTF8StringEncoding];
		NSString *escapedString = [stringData stringByReplacingOccurrencesOfString: @"&" withString: @"&amp;"];
		NSData *escapedData = [escapedString dataUsingEncoding: NSUTF8StringEncoding];
		
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData: escapedData];
		
		[parser setDelegate: self];						// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.

		[parser setShouldProcessNamespaces: NO];
		[parser setShouldReportNamespacePrefixes: NO];
		[parser setShouldResolveExternalEntities: NO];
		
		[parser parse];
		
		NSError *parseError = [parser parserError];
		if (parseError)
			NSLog (@"CDATA parse error: %@", parseError);
		
		[parser release];
		[stringData release];
	}
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
    if ([elementName isEqualToString: @"li"])
	{
        self.parsedTrendsCounter = parsedTrendsCounter + 1;
		if (parsedTrendsCounter < kTrendsInList)
		{
			self.currentTrendObject = [[Trend alloc] init];		 // A <li> entry in the RSS feed represents a trend, so create an instance of it.
			[trends addObject: currentTrendObject];
			[self.currentTrendObject release];
		}
    }
   else if ([elementName isEqualToString: @"content"])
	{
        NSString *typeAtt = [attributeDict valueForKey: @"type"];
        if ([typeAtt isEqualToString: @"html"])
		{
			self.parseCDATA = YES;
        }
    }
	else if ([elementName isEqualToString: @"span"])
	{
        NSString *classAtt = [attributeDict valueForKey: @"class"];
		NSArray *words = [classAtt componentsSeparatedByString: @" "];
		self.currentTrendObject.hotness = [words objectAtIndex: 0];		// Volcanic, On_Fire, Spicy, Medium, or Mild.
		self.currentTrendObject.previousRank = [words objectAtIndex: 1];	// new, equal, upnn, or down nn where nn is relative previous rank.
    }
	else if ([elementName isEqualToString: @"a"])
	{
		self.currentTrendObject.webLink = [[attributeDict valueForKey: @"href"] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        self.contentOfCurrentTrendProperty = @"";
    }
}



- (void) parser: (NSXMLParser *) parser didEndElement: (NSString *) elementName namespaceURI: (NSString *) namespaceURI qualifiedName: (NSString *) qName
{     
    if (qName)
        elementName = qName;
    if ([elementName isEqualToString: @"a"])
        self.currentTrendObject.title = [self.contentOfCurrentTrendProperty stringByReplacingOccurrencesOfString: @" s " withString: @"’s "];
    else if ([elementName isEqualToString: @"content"] && parseCDATA)
	{
		self.parseCDATA = NO;
		[(id) [[UIApplication sharedApplication] delegate] performSelectorOnMainThread: @selector (setTrendList:) withObject: self.trends waitUntilDone: YES];
///		[parser abortParsing];
///		[self dealloc];
///		[NSThread exit];
	}
}



- (void) parser: (NSXMLParser *) parser foundCharacters: (NSString *) string
{
    if (self.contentOfCurrentTrendProperty)			// If the current element is one whose content we care about, append 'string' to the property that holds the content of the current element.
		self.contentOfCurrentTrendProperty = [self.contentOfCurrentTrendProperty stringByAppendingString: string];
}

@end
