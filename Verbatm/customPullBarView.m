//
//  customPullBarView.m
//  Verbatm
//
//  Created by Iain Usiri on 1/10/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "customPullBarView.h"

@interface customPullBarView ()
@property (weak, nonatomic) IBOutlet UIButton *uibutton_Preview;
@property (weak, nonatomic) IBOutlet UIButton *uibutton_Keyboard;
@property (weak, nonatomic) IBOutlet UIButton *uibutton_Undo;

@end


@implementation customPullBarView


-(instancetype)initWithFrame:(CGRect)frame
{

    //load from Nib file..this initializes the background view and all its subviews
    self = [[[NSBundle mainBundle] loadNibNamed:@"customPullBar" owner:self options:nil]firstObject];
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
    self.uibutton_Keyboard.frame = CGRectMake(self.frame.size.width - self.uibutton_Keyboard.frame.size.width - undoXOffset, self.uibutton_Keyboard.frame.origin.y, self.uibutton_Keyboard.frame.size.width, self.uibutton_Keyboard.frame.size.height);
    
    NSInteger centerPoint = self.frame.size.width /2;
    self.uibutton_Preview.frame = CGRectMake(centerPoint - (self.uibutton_Preview.frame.size.width/2), self.uibutton_Preview.frame.origin.y, self.uibutton_Preview.frame.size.width, self.uibutton_Preview.frame.size.height);
}


//sends signal to the delegate that the button was pressed
- (IBAction)previewButtonTouched:(UIButton *)sender
{
    [self.customeDelegate previewButtonPressed];
    
}
//sends signal to the delegate that the button was pressed
- (IBAction)KeyboardButtonTouched:(UIButton *)sender
{
    [self.customeDelegate keyboardButtonPressed];
}


//sends signal to the delegate that the button was pressed
- (IBAction)undoBotton:(UIButton *)sender
{
    [self.customeDelegate undoButtonPressed];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
