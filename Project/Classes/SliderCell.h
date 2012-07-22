//  SliderCell.h
//  Copyright 2009 Michael Hourigan. All rights reserved.

#import <UIKit/UIKit.h>

@interface SliderCell: UITableViewCell
{
}

- (id) initWithValue: (float) defaultValue minimum: (float) minimum maximum: (float) maximum minimumImageName: (NSString *) minimumImageName maximumImageName: (NSString *) maximumImageName target: (id) target tag: (int) tag;

@end
