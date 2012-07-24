// TableViewCell.h - Custom table cell.
// Copyright 2012 Michael Hourigan. All rights reserved.
// Now under GNU open source license.

#import <UIKit/UIKit.h>
#import "Trend.h"

@interface TableViewCell: UITableViewCell
{
	Trend *trend;
    UILabel *trendLabel;
    UIImageView *hotnessImageView;
}

@property (nonatomic, retain) Trend *trend;
@property (nonatomic, retain) UILabel *trendLabel;
@property (nonatomic, retain) UIImageView *hotnessImageView;

- (UIImage *) imageForMagnitude: (NSString *) hotness;

- (Trend *) trend;
- (void) setTrend: (Trend *) newTrend;

@end
