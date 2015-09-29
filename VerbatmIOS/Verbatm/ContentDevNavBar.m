//
//  ContentDevNavBar.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/28/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "Icons.h"
#import "ContentDevNavBar.h"
#import "SizesAndPositions.h"
#import "Styles.h"

@interface ContentDevNavBar()

@property (strong, nonatomic) UIButton *backButton;

@property (strong, nonatomic) UIButton *previewButton;
@property (strong, nonatomic) UILabel *previewLabel;
@property (nonatomic) BOOL previewEnabledInMenuMode;

@end

@implementation ContentDevNavBar

# pragma mark Initialization
-(instancetype)initWithFrame:(CGRect)frame {

	self = [super initWithFrame:frame];
	if(self) {
		[self setBackgroundColor: [UIColor clearColor]];
		[self createButtons];
	}
	return self;
}

//initialize all buttons, for all modes
-(void)createButtons {

	CGRect backButtonFrame = CGRectMake(CONTENT_DEV_NAV_BAR_OFFSET, CONTENT_DEV_NAV_BAR_OFFSET, NAV_ICON_SIZE, NAV_ICON_SIZE);
	self.backButton = [self getButtonWithFrame: backButtonFrame];
	[self.backButton setImage:[UIImage imageNamed:BACK_ARROW_LEFT] forState:UIControlStateNormal];
	[self.backButton addTarget:self action:@selector(backButtonReleased:) forControlEvents:UIControlEventTouchUpInside];


	self.previewLabel = [self getLabelWithText:@"PREVIEW"];
	[self.previewLabel setTextColor:[UIColor PREVIEW_PUBLISH_COLOR]];

	CGRect expectedPreviewLabelSize = [self.previewLabel.text boundingRectWithSize: self.bounds.size
														options: NSStringDrawingTruncatesLastVisibleLine
													 attributes: @{NSFontAttributeName: self.previewLabel.font}
														context: nil];

	CGRect previewButtonFrame = CGRectMake(self.frame.size.width - expectedPreviewLabelSize.size.width -
										   CONTENT_DEV_NAV_BAR_OFFSET,
										   CONTENT_DEV_NAV_BAR_OFFSET,
										   expectedPreviewLabelSize.size.width, NAV_ICON_SIZE);
	[self.previewLabel setFrame: CGRectMake(0, 0, previewButtonFrame.size.width, previewButtonFrame.size.height)];
	self.previewButton = [self getButtonWithFrame: previewButtonFrame];
	[self.previewButton addTarget:self action:@selector(previewButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
	[self.previewButton addSubview:self.previewLabel];
	[self enablePreviewButton: NO];
}

-(UILabel*) getLabelWithText:(NSString*) text {
	UILabel* label = [[UILabel alloc] init];
	label.text = text;
	label.font = [UIFont fontWithName:PREVIEW_BUTTON_FONT size:PREVIEW_BUTTON_FONT_SIZE];
	label.textAlignment = NSTextAlignmentCenter;
	return label;
}

-(UIButton*) getButtonWithFrame: (CGRect)frame  {
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setFrame: frame];
	[button.imageView setContentMode: UIViewContentModeScaleAspectFit];
	[self addSubview: button];
	return button;
}

# pragma mark - Enable and unEnable Buttons -

-(void) enablePreviewButton: (BOOL) enable {
	if (enable) {
		[self.previewLabel setTextColor: [UIColor PREVIEW_PUBLISH_COLOR]];
	} else {
		[self.previewLabel setTextColor: [UIColor  colorWithRed:(2.f/3.f) green:(2.f/3.f) blue:(2.f/3.f) alpha:0.5]];
	}
	[self.previewButton setEnabled: enable];
}

# pragma mark - Button actions on touch up (send message to delegates)

-(void) backButtonReleased:(UIButton*) sender {
	if (!self.delegate) {
//		NSLog(@"No content dev pull bar delegate set.");
	}
	[self.delegate backButtonPressed];
}

- (void) previewButtonReleased:(UIButton *)sender {
	if (!self.delegate) {
//		NSLog(@"No content dev nav bar delegate set.");
	}
    [self.delegate previewButtonPressed];
}

@end
