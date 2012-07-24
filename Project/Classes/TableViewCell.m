// TableViewCell.m - Custom table cell.
// Copyright 2012 Michael Hourigan. All rights reserved.
// Now under GNU open source license.

#import "TableViewCell.h"

static UIImage *volcanicImage = nil;
static UIImage *onFireImage = nil;
static UIImage *spicyImage = nil;
static UIImage *mediumImage = nil;
static UIImage *mildImage = nil;

@interface TableViewCell ()
- (UILabel *) newLabelWithPrimaryColor: (UIColor *) primaryColor selectedColor: (UIColor *) selectedColor fontSize: (CGFloat) fontSize bold: (BOOL) bold;
@end

@implementation TableViewCell

@synthesize trend, trendLabel, hotnessImageView;



+ (void) initialize
{
    // The hotness images are cached as part of the class, so they need to be explicitly retained.
    volcanicImage = [[UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Volcanic.png" ofType: nil inDirectory: @"Images"]] retain];
    onFireImage = [[UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"On_Fire.png" ofType: nil inDirectory: @"Images"]] retain];
    spicyImage = [[UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Spicy.png" ofType: nil inDirectory: @"Images"]] retain];
    mediumImage = [[UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Medium.png" ofType: nil inDirectory: @"Images"]] retain];
    mildImage = [[UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Mild.png" ofType: nil inDirectory: @"Images"]] retain];
}



- (id) initWithFrame: (CGRect) frame reuseIdentifier: (NSString *) reuseIdentifier
{
    if (self = [super initWithStyle: UITableViewCellStyleDefault reuseIdentifier: reuseIdentifier])
	{
		// self.frame = frame;
        UIView *myContentView = self.contentView;
        
        // Add an image view to display the "hotness" of a trend.
		self.hotnessImageView = [[UIImageView alloc] initWithImage: spicyImage];
		[myContentView addSubview: self.hotnessImageView];
        [self.hotnessImageView release];
        
        // A label that displays the title of the trend.
        self.trendLabel = [self newLabelWithPrimaryColor: [UIColor blackColor] selectedColor: [UIColor whiteColor] fontSize: 24.0 bold: YES]; 
		self.trendLabel.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview: self.trendLabel];
		[self.trendLabel release];
        
        // Position the hotnessImageView above all of the other views so
        // it's not obscured. It's a transparent image, so any views
        // that overlap it will still be visible.
        [myContentView bringSubviewToFront: self.hotnessImageView];
    }
    return self;
}



- (void) dealloc
{
    [trend release];
    [trendLabel release];
    [hotnessImageView release];
	[super dealloc];
}



// Rather than using one of the standard UITableViewCell content properties like 'text',
// we're using a custom property called 'trend' to populate the table cell. Whenever the
// value of that property changes, we need to call [self setNeedsDisplay] to force the
// cell to be redrawn.
- (void) setTrend: (Trend *) newTrend
{
    trend = [newTrend retain];
    
    self.trendLabel.text = newTrend.title;
    self.hotnessImageView.image = [self imageForMagnitude: newTrend.hotness];
    
    [self setNeedsDisplay];
}



- (UIImage *) imageForMagnitude: (NSString *) hotness
{
	if ([hotness isEqualToString: @"Volcanic"])
		return volcanicImage;
	if ([hotness isEqualToString: @"On_Fire"])
		return onFireImage;
	if ([hotness isEqualToString: @"Spicy"])
		return spicyImage;
	if ([hotness isEqualToString: @"Medium"])
		return mediumImage;
	if ([hotness isEqualToString: @"Mild"])
		return mildImage;
	return nil;
}



- (void) layoutSubviews
{
    
#define LEFT_COLUMN_OFFSET 0
#define LEFT_COLUMN_WIDTH 40
#define RIGHT_COLUMN_WIDTH 270
#define UPPER_ROW_TOP 10
#define LOWER_ROW_TOP 28
    
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
	
    if (!self.editing)
	{
		
        CGFloat boundsX = contentRect.origin.x;
		CGRect frame;
        
        // Place the hotness image.
        UIImageView *imageView = self.hotnessImageView;
        frame = [imageView frame];
		frame.origin.x = boundsX + LEFT_COLUMN_OFFSET + (LEFT_COLUMN_WIDTH - imageView.image.size.width) / 2;
		frame.origin.y = 10;
 		imageView.frame = frame;
        
        // Place the text.
		self.trendLabel.frame = CGRectMake (boundsX + LEFT_COLUMN_OFFSET + LEFT_COLUMN_WIDTH, UPPER_ROW_TOP, RIGHT_COLUMN_WIDTH, LOWER_ROW_TOP);
    }
}



- (void) setSelected: (BOOL) selected animated: (BOOL) animated
{
	// Views are drawn most efficiently when they are opaque and do not have a clear background, so in newLabelForMainText: the labels are made opaque and given a white background.  To show selection properly, however, the views need to be transparent (so that the selection color shows through).  
	[super setSelected: selected animated: animated];
	
	UIColor *backgroundColor = nil;
	if (selected)
	    backgroundColor = [UIColor clearColor];
	else
		backgroundColor = [UIColor whiteColor];
    
	self.trendLabel.backgroundColor = backgroundColor;
	self.trendLabel.highlighted = selected;
	self.trendLabel.opaque = !selected;
}



- (UILabel *) newLabelWithPrimaryColor: (UIColor *) primaryColor selectedColor: (UIColor *) selectedColor fontSize: (CGFloat) fontSize bold: (BOOL) bold
{
	// Create and configure a label.

    UIFont *font;
    if (bold)
        font = [UIFont boldSystemFontOfSize: fontSize];
	else
        font = [UIFont systemFontOfSize: fontSize];
    
    // Views are drawn most efficiently when they are opaque and do not have a clear background, so set these defaults.  To show selection properly, however, the views need to be transparent (so that the selection color shows through).  This is handled in setSelected: animated:.
	UILabel *newLabel = [[UILabel alloc] initWithFrame: CGRectZero];		//??? Trace the retain count to see if this should be autoreleased here.
	newLabel.backgroundColor = [UIColor whiteColor];
	newLabel.opaque = YES;
	newLabel.textColor = primaryColor;
	newLabel.highlightedTextColor = selectedColor;
	newLabel.font = font;
	
	return newLabel;
}

@end
