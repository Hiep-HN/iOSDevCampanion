// TrendsListViewController.h - Standard table view controller.

#import <UIKit/UIKit.h>

@interface TrendsListViewController: UITableViewController <UITableViewDataSource>
{
	NSArray *trends;
	NSString *firstEntry;
	NSString *placeholder;
}

@property (nonatomic, retain) NSArray *trends;
@property (nonatomic, retain) NSString *firstEntry;
@property (nonatomic, retain) NSString *placeholder;

- (id) initWithTrends: (NSArray *) trendArray firstEntry: (NSString *) firstEntryTitle placeholder: (NSString *) placeholderText;

@end
