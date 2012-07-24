// SliderCell.h
// Copyright 2012 Michael Hourigan. All rights reserved.
// Now under GNU open source license.

#import <UIKit/UIKit.h>

@interface SliderCell: UITableViewCell
{
}

- (id) initWithValue: (float) defaultValue minimum: (float) minimum maximum: (float) maximum minimumImageName: (NSString *) minimumImageName maximumImageName: (NSString *) maximumImageName target: (id) target tag: (int) tag;

@end
