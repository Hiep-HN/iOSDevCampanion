// SliderCell.m
// Copyright 2012 Michael Hourigan. All rights reserved.
// Now under GNU open source license.

#import "SliderCell.h"

@implementation SliderCell



- (id) initWithValue: (float) defaultValue minimum: (float) minimum maximum: (float) maximum minimumImageName: (NSString *) minimumImageName maximumImageName: (NSString *) maximumImageName target: (id) target tag: (int) tag
{
	if (self = [self initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"Slider cell"])
	{
		// frame = self.contentView.frame;
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		UISlider *newSlider = [[UISlider alloc] initWithFrame: CGRectOffset (CGRectInset (self.frame, 30, 12), -10, 0)];
		[newSlider addTarget: target action: @selector (sliderAction:) forControlEvents: UIControlEventValueChanged];
		newSlider.backgroundColor = [UIColor clearColor];	// in case the parent view draws with a custom color or gradient, use a transparent color.
		newSlider.minimumValue = minimum;
		newSlider.maximumValue = maximum;
		newSlider.continuous = YES;
		newSlider.value = defaultValue;
		newSlider.minimumValueImage = [[UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: minimumImageName ofType: nil inDirectory: @"Images"]] retain];
		newSlider.maximumValueImage = [[UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: maximumImageName ofType: nil inDirectory: @"Images"]] retain];
		newSlider.tag = tag;
		[self.contentView addSubview: newSlider];
		[newSlider release];
	}
	return self;
}



- (void) setSelected: (BOOL) selected animated: (BOOL) animated
{

	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}



- (void) dealloc
{
	[super dealloc];
}

@end
