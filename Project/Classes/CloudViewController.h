//  CloudViewController.h
//  Copyright 2009 Michael Hourigan. All rights reserved.

#import <UIKit/UIKit.h>
#import "Trend.h"


@interface CloudViewController: UIViewController
{
	Trend *		trend;		// Which trend this is carrying across the screen. Determines the text, size, color, speed, and other visual attributes.
	float		speed;		// Pixels per hundredth of a second.
}

@property (nonatomic, retain) Trend *trend;
@property (assign) float speed;

- (id) initWithTrend: (Trend *) trend;

@end
