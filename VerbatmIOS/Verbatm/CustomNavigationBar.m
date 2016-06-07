//
//  ContentDevNavBar.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/28/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "Icons.h"
#import "CustomNavigationBar.h"
#import "SizesAndPositions.h"
#import "Styles.h"

@interface CustomNavigationBar()

#define OFFSET 15.f
#define BUTTON_WIDTH self.frame.size.width/3.f
#define BUTTON_HEIGHT self.frame.size.height
#define TITLE_FONT_SIZE 24.f
#define BUTTON_IMAGE_Y_OFFSET 5.f

@end

@implementation CustomNavigationBar

-(instancetype)initWithFrame:(CGRect)frame andBackgroundColor: (UIColor*) backgroundColor {
	self = [super initWithFrame:frame];
	if(self) {
		[self setBackgroundColor: backgroundColor];
	}
	return self;
}

#pragma mark - Create Buttons -

-(void) createLeftButtonWithTitle: (NSString*) title orImage: (UIImage*) image {
	UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[leftButton setFrame: CGRectMake(0.f, 0.f, BUTTON_WIDTH, BUTTON_HEIGHT)];
	if (title) {
		UILabel* titleLabel = [self getLabelWithText:title andAlignment:NSTextAlignmentLeft];
		titleLabel.frame = CGRectMake(OFFSET, 0.f, BUTTON_WIDTH - OFFSET, BUTTON_HEIGHT);
		[leftButton addSubview:titleLabel];
	} else if (image) {
		[leftButton.imageView setContentMode: UIViewContentModeScaleAspectFit];
		leftButton.imageEdgeInsets = UIEdgeInsetsMake(BUTTON_IMAGE_Y_OFFSET, OFFSET, BUTTON_IMAGE_Y_OFFSET,
													  BUTTON_WIDTH - OFFSET - (BUTTON_HEIGHT - 2*BUTTON_IMAGE_Y_OFFSET));
		[leftButton setImage:image forState:UIControlStateNormal];
	}
	[self addSubview: leftButton];
	[leftButton addTarget:self action:@selector(leftButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(void) createMiddleButtonWithTitle: (NSString*) title orImage: (UIImage*) image {
	UIButton* middleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[middleButton setFrame: CGRectMake(BUTTON_WIDTH, 0.f, BUTTON_WIDTH, BUTTON_HEIGHT)];
	if (title) {
		UILabel* titleLabel = [self getLabelWithText:title andAlignment:NSTextAlignmentCenter];
		[middleButton addSubview:titleLabel];
	} else if (image) {
		[middleButton.imageView setContentMode: UIViewContentModeCenter];
		[middleButton setImage:image forState:UIControlStateNormal];
	}
	[self addSubview: middleButton];
	[middleButton addTarget:self action:@selector(middleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

//called instead of the middle button  -- don't call both
-(void) createMiddleTitleWithText: (NSString*) title{
    UILabel* titleLabel = [self getTitleLabelWithText:title];
    [self addSubview:titleLabel];
}


-(void) createRightButtonWithTitle: (NSString*) title orImage: (UIImage*) image {
	UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightButton setFrame: CGRectMake(BUTTON_WIDTH*2, 0.f, BUTTON_WIDTH, BUTTON_HEIGHT)];
	if (title) {
		UILabel* titleLabel = [self getLabelWithText:title andAlignment:NSTextAlignmentRight];
		titleLabel.frame = CGRectMake(0.f, 0.f, BUTTON_WIDTH - OFFSET, BUTTON_HEIGHT);
		[rightButton addSubview:titleLabel];
	} else if (image) {
		[rightButton.imageView setContentMode: UIViewContentModeRight];
		[rightButton setImage:image forState:UIControlStateNormal];
	}
	[self addSubview: rightButton];
	[rightButton addTarget:self action:@selector(rightButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(UILabel*) getLabelWithText:(NSString*) text andAlignment: (NSTextAlignment) alignment {
	UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, BUTTON_WIDTH, BUTTON_HEIGHT)];
	label.text = text;
	label.font = [UIFont fontWithName:NAVIGATION_BAR_BUTTON_FONT size:NAVIGATION_BAR_BUTTON_FONT_SIZE];
	label.textAlignment = alignment;
	label.textColor = [UIColor NAVIGATION_BAR_TEXT_COLOR];
	return label;
}


-(UILabel *) getTitleLabelWithText:(NSString *) text{
    CGRect labelFrame = CGRectMake(BUTTON_WIDTH, 0.f, BUTTON_WIDTH, BUTTON_HEIGHT);
    UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
    label.text = text;
    label.font = [UIFont fontWithName:BOLD_FONT size:TITLE_FONT_SIZE];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor NAVIGATION_BAR_TEXT_COLOR];
    return label;
}

# pragma mark - Button actions -

-(void) leftButtonPressed:(UIButton*) sender {
	[self.delegate leftButtonPressed];
}

- (void) middleButtonPressed:(UIButton *)sender {
    [self.delegate middleButtonPressed];
}

- (void) rightButtonPressed:(UIButton *)sender {
	[self.delegate rightButtonPressed];
}

@end
