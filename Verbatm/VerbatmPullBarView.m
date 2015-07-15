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
@property (weak, nonatomic) IBOutlet UIButton *uibutton_Preview;
@property (weak, nonatomic) IBOutlet UIButton *uibutton_Keyboard;
@property (weak, nonatomic) IBOutlet UIButton *uibutton_Undo;
@property (weak, nonatomic) IBOutlet UIButton *save_button;

#define CENTER_BUTTON_GAP 10
@end


@implementation VerbatmPullBarView

-(instancetype)initWithFrame:(CGRect)frame
{

    //load from Nib file..this initializes the background view and all its subviews
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"VerbatmPullBarView" owner:self options:nil]firstObject];
    if(self)
    {
        
        self.frame = frame;
        [self centerButtons];
    }
    return self;
}



-(void)centerButtons
{
    //get the xoffset for the undo button and ensure the the keyboardbutton has the same offset
    NSInteger undoXOffset = self.uibutton_Undo.frame.origin.x;
     NSInteger centerPoint = self.frame.size.width /2;
    
    //self.uibutton_Keyboard.frame = CGRectMake(self.frame.size.width - self.uibutton_Keyboard.frame.size.width - undoXOffset, self.uibutton_Keyboard.frame.origin.y, self.uibutton_Keyboard.frame.size.width, self.uibutton_Keyboard.frame.size.height);
    //self.uibutton_Preview.frame = CGRectMake(centerPoint - (self.uibutton_Preview.frame.size.width + CENTER_BUTTON_GAP), self.uibutton_Preview.frame.origin.y, self.uibutton_Preview.frame.size.width, self.uibutton_Preview.frame.size.height);
    //self.save_button.frame =CGRectMake(centerPoint + CENTER_BUTTON_GAP, self.uibutton_Preview.frame.origin.y, self.save_button.frame.size.width, self.uibutton_Preview.frame.size.height);
    
     self.uibutton_Preview.frame = CGRectMake(centerPoint - (self.uibutton_Preview.frame.size.width/2), self.uibutton_Preview.frame.origin.y, self.uibutton_Preview.frame.size.width, self.uibutton_Preview.frame.size.height);
    self.save_button.frame =CGRectMake(self.frame.size.width - self.save_button.frame.size.width - undoXOffset , self.save_button.frame.origin.y, self.save_button.frame.size.width, self.save_button.frame.size.height);
}
- (IBAction)saveButton_Touched:(UIButton *)sender
{
    //we have issue here when the button is pressed with the text entry up
    if(![self.customDelegate isKindOfClass:[VerbatmImageScrollView class]])[self.customDelegate saveButtonPressed];
}


//sends signal to the delegate that the button was pressed
- (IBAction)previewButtonTouched:(UIButton *)sender
{
    [self.customDelegate previewButtonPressed];
    
}
//sends signal to the delegate that the button was pressed
- (IBAction)KeyboardButtonTouched:(UIButton *)sender
{
    return;//removing this feature for now
    [self.customDelegate keyboardButtonPressed];
}


//sends signal to the delegate that the button was pressed
- (IBAction)undoBotton:(UIButton *)sender
{
    [self.customDelegate undoButtonPressed];
}


@end
