// TrendsListViewController.m - Standard table view controller.

#import "TrendsListViewController.h"
#import "AppController.h"
#import "TableViewCell.h"

@implementation TrendsListViewController
@synthesize trends, firstEntry, placeholder;



- (id) initWithTrends: (NSArray *) trendArray firstEntry: (NSString *) firstEntryTitle placeholder: (NSString *) placeholderText
{
	if (self = [self initWithStyle: UITableViewStylePlain])
	{
		self.trends = trendArray;
		self.firstEntry = firstEntryTitle;
		self.placeholder = placeholderText;
		self.title = NSLocalizedString (@"Trends", @"TrendsListViewController title");
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.rowHeight = 48.0;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.sectionHeaderHeight = 0;
		
		UIBarButtonItem *editButton;
		if (firstEntry == nil)						// This is a history list, not a bookmarks list.
			editButton = [[UIBarButtonItem alloc] initWithTitle: @"Clear" style: UIBarButtonItemStyleBordered target: self action: @selector (clearHistoryAction:)];
		else
			editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemEdit target: self action: @selector (editAction:)];
		editButton.enabled = ([trends count] != 0);
		self.navigationItem.rightBarButtonItem = editButton;
		[editButton release];
	}
	return self;
}



- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
	return 1;
}



- (void) dealloc
{
	[trends release];
	[firstEntry release];
	[placeholder release];
	[super dealloc];
}



- (void) viewWillAppear: (BOOL) animated
{
	if (firstEntry)			// This is not a history list. Make sure this is an Edit button instead of the History's Clear button.
	{
		UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemEdit target: self action: @selector (editAction:)];
		editButton.enabled = ([trends count] != 0);
		self.navigationItem.rightBarButtonItem = editButton;
		[editButton release];
	}
	else
	{
		AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
		if (appDelegate.history == nil)
			appDelegate.history = [[appDelegate readTrendsWithKey: kHistorySettingKey] mutableCopy];
		if ([appDelegate.history count] == 0)
			self.navigationItem.rightBarButtonItem.enabled = NO;			// Disable the Clear button, since there aren't any entries clear.
	}
}



- (void) editAction: (id) sender
{
	[self.tableView setEditing: YES animated: YES];

	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone target: self action: @selector (doneEditingAction:)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];

	self.navigationItem.leftBarButtonItem = nil;
}



- (void) doneEditingAction: (id) sender
{
	[self.tableView setEditing: NO animated: YES];
	
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemEdit target: self action: @selector (editAction:)];
	editButton.enabled = ([trends count] != 0);
	self.navigationItem.rightBarButtonItem = editButton;
	[editButton release];
	
	AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone target: appDelegate.trendsViewController action: @selector (doneAction:)];
	self.navigationItem.leftBarButtonItem = doneButton;
	[doneButton release];
}



- (void) clearHistoryAction: (id) sender
{
	AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
	[appDelegate.history removeAllObjects];							// Remove all trends from the history list.
	[appDelegate saveTrends: appDelegate.history withKey: kHistorySettingKey];					// Write empty list out to settings.
	[self.tableView reloadData];									// Tell the list to update itself.
	self.navigationItem.rightBarButtonItem.enabled = NO;			// Disable the Clear button, since there aren't any entries clear anymore.
}



- (void) history
{
	AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
	if (appDelegate.history == nil)
		appDelegate.history = [[appDelegate readTrendsWithKey: kHistorySettingKey] mutableCopy];
	TrendsListViewController *trendsListViewController = [[TrendsListViewController alloc] initWithTrends: appDelegate.history firstEntry: nil placeholder: @"No trends in history list"];
	
	UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle: @"Clear" style: UIBarButtonItemStyleBordered target: self action: @selector (clearHistoryAction:)];
	self.navigationItem.rightBarButtonItem = clearButton;
	[clearButton release];
	
	trendsListViewController.title = @"History";
	[self.navigationController pushViewController: trendsListViewController animated: YES];
	[trendsListViewController release];
}



#pragma mark UITableViewDelegate

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
	int count = [trends count] + (firstEntry ? 1 : 0);	// There may be a special first entry such as "History" in the list of bookmarks.
	if ([trends count] == 0)		// Make an entry to say there are no saved bookmarks.
        count++;
    return count;
}



- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{	
	if (firstEntry && indexPath.row == 0)
		[self history];
	else if ([trends count] > 0)
	{
		AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
		[appDelegate showTrendInfo: ((TableViewCell *) [tableView cellForRowAtIndexPath: indexPath]).trend action: kGoogleHotTrends /* settings.action */ ];		// Now open the Google Hot Trends link.
	}
}



- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
	int row = indexPath.row;
    
	if (firstEntry && row == 0)		// The first list entry will be "History" with the standard history icon.
	{
		TableViewCell *cell = (TableViewCell *) [tableView dequeueReusableCellWithIdentifier: @"HistoryCell"];
		if (cell == nil)
			cell = [[[TableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"HistoryCell"] autorelease];
		cell.trendLabel.text = @"History";
		cell.hotnessImageView.image = [[UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"History.png" ofType: nil inDirectory: @"Images"]] retain];
		
		CGRect frame = cell.hotnessImageView.frame;		// Set image view's size based on size of its image.
		frame.size = cell.hotnessImageView.image.size;
		cell.hotnessImageView.frame = frame;
		
		cell.accessoryType = UITableViewCellAccessoryNone;
		[cell layoutSubviews];
		return cell;
	}
	
    // If the RSS feed isn't accessible (which could happen if the network isn't available), show an informative message in the first row of the table.
	if ([trends count] == 0)
	{
		UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier: @"PlaceholderCell"];
 		if (cell == nil)
			cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"PlaceholderCell"] autorelease];
		cell.textLabel.text = NSLocalizedString (placeholder, placeholder);
		cell.textLabel.textColor = [UIColor colorWithWhite: 0.5 alpha: 0.5];
		cell.accessoryType = UITableViewCellAccessoryNone;
		[cell layoutSubviews];
		return cell;
	}
	
	TableViewCell *cell = (TableViewCell *) [tableView dequeueReusableCellWithIdentifier: @"TrendCell"];
	if (cell == nil)
		cell = [[[TableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"TrendCell"] autorelease];
    // Set up the cell.
    
	if (firstEntry)
		row--;		// If History is first entry, decrement index to get proper index into trends array.
	Trend *trend = [trends objectAtIndex: row];
    [cell setTrend: trend];
	[cell layoutSubviews];
	return cell;
}



- (UITableViewCellEditingStyle) tableView: (UITableView *) tableView editingStyleForRowAtIndexPath: (NSIndexPath *) indexPath
{
	if (firstEntry && indexPath.row == 0)				// Don't allow deleting of "History" label at top.
		return UITableViewCellEditingStyleNone;
	if ([trends count] == 0)							// Don't allow deleting of "There are no bookmarks" label.
		return UITableViewCellEditingStyleNone;
	return UITableViewCellEditingStyleDelete;
}



#pragma mark UITableViewDataSource

- (void) tableView: (UITableView *) tableView commitEditingStyle: (UITableViewCellEditingStyle) editingStyle forRowAtIndexPath: (NSIndexPath *) indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
		[appDelegate.bookmarks removeObjectAtIndex: indexPath.row - 1];										// Delete item from array.
		[appDelegate saveTrends: appDelegate.bookmarks withKey: kBookmarksSettingKey];						// Re-save bookmarks.
		[tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath] withRowAnimation: YES];		// Delete entry from list. This must now (3.0) be done AFTER it is removed from the data source.
		[tableView reloadData];																				// Reload list to fill in last entry on page after others moved up.
	}
}

@end

