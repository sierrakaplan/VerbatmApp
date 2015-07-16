//
//  customPullBarView.m
//  Verbatm
//
//  Created by Iain Usiri on 1/10/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "VerbatmPullBarView.h"
#import "VerbatmImageScrollView.h"

@interface VerbatmPullBarView ()
@property (strong, nonatomic) UIButton *previewButton;
@property (strong, nonatomic) UIButton *undoButton;
@property (strong, nonatomic) UIImageView *pullUpIcon;

#define CENTER_BUTTON_GAP 20.f
#define XOFFSET 20.f
#define YOFFSET 5.f

#define UNDO_BUTTON_IMAGE @"undo_button_icon"
#define PREVIEW_BUTTON_IMAGE @"preview_button_icon"
#define PULLUP_ICON_IMAGE @"pullup_icon"

@end


@implementation VerbatmPullBarView

-(instancetype)initWithFrame:(CGRect)frame
{

    //load from Nib file..this initializes the background view and all its subviews
    self = [super initWithFrame:frame];
    if(self)
    {
        self.frame = frame;
        [self createButtons];
    }
    return self;
}



-(void)createButtons {

	float centerPoint = self.frame.size.width /2.f;
	float buttonSize = self.frame.size.height - (2.f * YOFFSET);

	CGRect undoButtonFrame = CGRectMake(XOFFSET, YOFFSET, buttonSize, buttonSize);
	self.undoButton = [[UIButton alloc] initWithFrame:undoButtonFrame];
	[self.undoButton setBackgroundImage:[UIImage imageNamed:UNDO_BUTTON_IMAGE] forState:UIControlStateNormal];
	[self.undoButton addTarget:self action:@selector(undoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

	CGRect pullUpIconFrame = CGRectMake(centerPoint-buttonSize/2.f, YOFFSET, buttonSize, buttonSize);
	self.pullUpIcon = [[UIImageView alloc] initWithFrame:pullUpIconFrame];
	[self.pullUpIcon setImage:[UIImage imageNamed:PULLUP_ICON_IMAGE]];


	CGRect previewButtonFrame = CGRectMake(self.frame.size.width - buttonSize - XOFFSET, YOFFSET, buttonSize, buttonSize);
	self.previewButton = [[UIButton alloc] initWithFrame:previewButtonFrame];
	[self.previewButton setBackgroundImage:[UIImage imageNamed:PREVIEW_BUTTON_IMAGE] forState:UIControlStateNormal];
	[self.previewButton addTarget:self action:@selector(previewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

	[self addSubview:self.undoButton];
	[self addSubview:self.pullUpIcon];
	[self addSubview:self.previewButton];
}

//- (IBAction)saveButton_Touched:(UIButton *)sender
//{
//    //we have issue here when the button is pressed with the text entry up
//    if(![self.customDelegate isKindOfClass:[VerbatmImageScrollView class]])[self.customDelegate saveButtonPressed];
//}


//sends signal to the delegate that the button was pressed
- (IBAction)previewButtonPressed:(UIButton *)sender
{
    [self.customDelegate previewButtonPressed];
    
}
////sends signal to the delegate that the button was pressed
//- (IBAction)KeyboardButtonTouched:(UIButton *)sender
//{
//    return;//removing this feature for now
//    [self.customDelegate keyboardButtonPressed];
//}


//sends signal to the delegate that the button was pressed
- (IBAction)undoButtonPressed:(UIButton *)sender
{
    [self.customDelegate undoButtonPressed];
}


@end
