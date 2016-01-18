//
//  SharePOVView.m
//  Verbatm
//
//  Created by Iain Usiri on 1/2/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "SharePOVView.h"
#import "SelectSharingOption.h"
#import "SelectChannel.h"


#define SHARE_BUTTON_HEIGHT 40.f
#define BUTTON_WALL_OFFSET_X  10.f
#define ANIMATION_DURATION 0.5

@interface SharePOVView () <SelectSharingOptionProtocol, SelectChannelProtocol, UITextFieldDelegate>
@property (nonatomic) SelectSharingOption * sharingOption;
@property (nonatomic) SelectChannel * channelSelectionOptions;
@property (nonatomic) UIButton * reportButton;
@property (nonatomic) UIButton * shareButton;
@property (nonatomic) UIButton * cancelButton;

@property (nonatomic) NSArray * userChannels;


@property (nonatomic) CGRect channelSelectionFrameOFFSCREEN;
@property (nonatomic) CGRect channelSelectionStartFrameONSCREEN;

@property (nonatomic) CGRect shareOptionSelectionStartFrameOFFSCREEN;
@property (nonatomic) CGRect shareOptionSelectionStartFrameONSCREEN;

@property (nonatomic) CGFloat keyboardHeight;

@property (nonatomic) UITextField * facebookCommentTextField;

@property (nonatomic) Channel * selectedChannel;


@property (nonatomic) BOOL showChannels;

#define TEXT_VIEW_HEIGHT 50

@end


@implementation SharePOVView

-(instancetype) initWithFrame:(CGRect)frame andChannels:(NSArray *) userChannels shouldStartOnChannels:(BOOL) showChannels{
    self = [super initWithFrame:frame];
    if (self) {
        [self formatView];
        self.userChannels = userChannels;
        self.showChannels = showChannels;
        [self createListFrames];
        if(showChannels){
            [self presentUserChannelsToFollow];
        }else{
          [self createSelections];
        }
    }
    return self;
}



-(void)presentUserChannelsToFollow {
    [self createReportAndCancelButtonsCancelFullScreen:YES];
    [self createShareOrFollowButton_isShare:NO];
    [self showChannelSelection:YES];
}


-(void)formatView{
    self.backgroundColor = [UIColor blackColor];
}

-(void)createSelections{
    
    [self createReportAndCancelButtonsCancelFullScreen:NO];

    self.sharingOption = [[SelectSharingOption alloc] initWithFrame:self.shareOptionSelectionStartFrameONSCREEN];
    [self addSubview:self.sharingOption];
    self.sharingOption.delegate = self;
    
    [self createShareOrFollowButton_isShare:YES];
    
}


-(void)createShareOrFollowButton_isShare:(BOOL) isShareButton {
    
    NSString * titleText = (isShareButton) ? @"SHARE" : @"FOLLOW" ;
    
    //create share button
    CGRect shareButtonFrame = CGRectMake(BUTTON_WALL_OFFSET_X, self.shareOptionSelectionStartFrameONSCREEN.origin.y + self.shareOptionSelectionStartFrameONSCREEN.size.height, self.frame.size.width - (BUTTON_WALL_OFFSET_X * 2), SHARE_BUTTON_HEIGHT - 10.f);
    
    self.shareButton =  [[UIButton alloc] initWithFrame:shareButtonFrame];
    [self.shareButton setTitle:titleText forState:UIControlStateNormal];
    self.shareButton.backgroundColor = [UIColor clearColor];
    
    self.shareButton.layer.cornerRadius = 4.f;
    self.shareButton.layer.borderWidth = 1.f;
    self.shareButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    if(isShareButton){
        [self.shareButton addTarget:self action:@selector(shareButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    }else {
        [self.shareButton addTarget:self action:@selector(followButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    }
    [self addSubview:self.shareButton];

}

//if the cancel button is full screen then we don't have report
-(void)createReportAndCancelButtonsCancelFullScreen:(BOOL) cancelButonFullscreen {
    CGRect cancelButtonFrame;
    if(cancelButonFullscreen) {
        cancelButtonFrame = CGRectMake(0.f, 0.f, self.frame.size.width, SHARE_BUTTON_HEIGHT);
    }else{
        //we add the -2.f so that the right/left border lines aren't visible
        CGRect reportButtonFrame = CGRectMake(-2.f, 0.f, (self.frame.size.width/2.f) + 2.f, SHARE_BUTTON_HEIGHT);
        
        cancelButtonFrame = CGRectMake((self.frame.size.width/2.f), 0.f, (self.frame.size.width/2.f)+ 2.f, SHARE_BUTTON_HEIGHT);

        
        self.reportButton =  [[UIButton alloc] initWithFrame:reportButtonFrame];
        [self.reportButton  setTitle:@"REPORT" forState:UIControlStateNormal];
        self.reportButton .backgroundColor = [UIColor clearColor];
        
        self.reportButton .layer.cornerRadius = 1.f;
        self.reportButton .layer.borderWidth = 1.f;
        self.reportButton .layer.borderColor = [UIColor whiteColor].CGColor;
        
        [self.reportButton addTarget:self action:@selector(reportButtonSelected) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.reportButton];
    }
    
    
    
    self.cancelButton = [[UIButton alloc] initWithFrame:cancelButtonFrame];
    [self.cancelButton  setTitle:@"CANCEL" forState:UIControlStateNormal];
    self.cancelButton .backgroundColor = [UIColor clearColor];
    
    self.cancelButton .layer.cornerRadius = 1.f;
    self.cancelButton .layer.borderWidth = 1.f;
    self.cancelButton .layer.borderColor = [UIColor whiteColor].CGColor;
    [self.cancelButton addTarget:self action:@selector(cancelButtonSelcted) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelButton];
    
    
}

-(void)cancelButtonSelcted {
    [self.delegate cancelButtonSelected];
}

-(void)reportButtonSelected {
    if([self.reportButton.titleLabel.text isEqualToString:@"REPORT"]){
        [self createReportAlert];
    }else{//it says back so lets go back
        [self showChannelSelection:NO];
        [self.shareButton setTitle:@"SHARE" forState:UIControlStateNormal];
        [self.reportButton setTitle:@"REPORT" forState:UIControlStateNormal];
    }
}

-(void) createReportAlert {
    //apply two step deletion
    UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"Report Post" message:@"Hey - what don't you like about this post? Let us know. Thank you!" preferredStyle:UIAlertControllerStyleAlert];
    
    [newAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        //no edits 
    }];
    
    
    UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"Send" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        
                                                        [self sendReport:action];
                                                    }];
    
    UIAlertAction* action2 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {}];
    [newAlert addAction:action1];
    [newAlert addAction:action2];
    UIViewController *currentTopVC = [self currentTopViewController];
    
    [currentTopVC presentViewController:newAlert animated:YES completion:nil];
}


-(void)sendReport:(UIAlertAction *) action {
    
//get text from action textfields
    
}



//hack -- to get main view controller to present an alertview
- (UIViewController *)currentTopViewController {
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController){
        topVC = topVC.presentedViewController;
    }
    return topVC;
}



-(void)followButtonSelected {
    //just to clear the view
    [self.delegate cancelButtonSelected];
}


-(void)shareButtonSelected {
    if([self.shareButton.titleLabel.text isEqualToString:@"SHARE"]){//sharing to social media
        //for now they have selected facebook
        NSString * comment = @"";
        if(self.facebookCommentTextField){
            comment = self.facebookCommentTextField.text;
        }
        [self.delegate sharePostWithComment:comment];
        
    }else if ([self.shareButton.titleLabel.text isEqualToString:@"POST"]){//Posting to a channel
        
        if(self.selectedChannel){
            [self.delegate postPOVToChannel:self.selectedChannel];
        }
    }
}

//channel selection protocol

-(void) channelsSelected:(NSMutableArray *) channels{
    self.selectedChannel = [channels firstObject];
}


//shareoptions button protocol
//called when an option is selected
-(void)shareOptionSelected:(ShareOptions) shareOption{
    if(shareOption == Verbatm){
        [self removeFacebookCommentView];
        [self showChannelSelection:YES];
        [self.shareButton setTitle:@"POST" forState:UIControlStateNormal];
        [self.reportButton setTitle:@"BACK" forState:UIControlStateNormal];
    }else if (shareOption == Facebook){
        [self createAndPrepareTextView];
    }
}

-(void)shareOptionDeselected:(ShareOptions) shareOption{
   if(shareOption == Facebook){
       [self removeFacebookCommentView];
    }
}

-(void) removeFacebookCommentView{
    if(self.facebookCommentTextField){
        [self.facebookCommentTextField removeFromSuperview];
        self.facebookCommentTextField = nil;
    }
}

-(void)createAndPrepareTextView {
    
    CGRect frame = CGRectMake(0.f, -TEXT_VIEW_HEIGHT , self.frame.size.width, TEXT_VIEW_HEIGHT);
    self.facebookCommentTextField = [[UITextField alloc] initWithFrame:frame];
    self.facebookCommentTextField.backgroundColor = [UIColor blackColor];
    self.facebookCommentTextField.textColor = [UIColor whiteColor];
    UIColor * color = [UIColor whiteColor];
    self.facebookCommentTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString: @"Add a comment..." attributes:@{NSForegroundColorAttributeName: color}];
    self.facebookCommentTextField.returnKeyType = UIReturnKeyDone;
    [self addSubview:self.facebookCommentTextField];
    [self.facebookCommentTextField becomeFirstResponder];
    self.facebookCommentTextField.delegate = self;
    
    self.clipsToBounds = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.facebookCommentTextField resignFirstResponder];
    return  NO;
}


-(void)registerForKeyboardNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}


//When keyboard appears get its height. This is only neccessary when the keyboard first appears
-(void)keyboardWillShow:(NSNotification *) notification {
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    //store the keyboard height for further use
    self.keyboardHeight = MIN(keyboardSize.height,keyboardSize.width);
}

-(void)keyBoardWillChangeFrame: (NSNotification *) notification {
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    //store the keyboard height for further use
    self.keyboardHeight = keyboardSize.height;
}


-(void) showChannelSelection:(BOOL) shouldShow{
    if(shouldShow){
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.channelSelectionOptions.frame = self.channelSelectionStartFrameONSCREEN;
            self.sharingOption.frame = self.shareOptionSelectionStartFrameOFFSCREEN;
            
            [self.channelSelectionOptions unselectAllOptions];
        }];
    }else{
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.channelSelectionOptions.frame = self.channelSelectionFrameOFFSCREEN;
            self.sharingOption.frame = self.shareOptionSelectionStartFrameONSCREEN;
            [self.sharingOption unselectAllOptions];
        }];
    }
}

//frames of the channel list and the share options list
-(void)createListFrames{
    //create bar with all our share options
    self.shareOptionSelectionStartFrameONSCREEN = CGRectMake(0.f, SHARE_BUTTON_HEIGHT,
                                                             self.frame.size.width, self.frame.size.height- (SHARE_BUTTON_HEIGHT * 2.f));
    
    self.shareOptionSelectionStartFrameOFFSCREEN = CGRectMake(- self.frame.size.width,
                                                              SHARE_BUTTON_HEIGHT,
                                                              self.frame.size.width, self.frame.size.height- (SHARE_BUTTON_HEIGHT * 2.f));
    
    self.channelSelectionFrameOFFSCREEN = CGRectMake(self.frame.size.width, self.shareOptionSelectionStartFrameOFFSCREEN.origin.y, self.shareOptionSelectionStartFrameOFFSCREEN.size.width, self.shareOptionSelectionStartFrameOFFSCREEN.size.height);
    self.channelSelectionStartFrameONSCREEN = CGRectMake(0.f, self.shareOptionSelectionStartFrameONSCREEN.origin.y, self.shareOptionSelectionStartFrameONSCREEN.size.width, self.shareOptionSelectionStartFrameONSCREEN.size.height);
}

-(SelectChannel *) channelSelectionOptions{
    if(!_channelSelectionOptions) {
        _channelSelectionOptions = [[SelectChannel alloc] initWithFrame:self.channelSelectionFrameOFFSCREEN andChannels:self.userChannels canSelectMultiple:self.showChannels];
        _channelSelectionOptions.delegate = self;
        [self addSubview:_channelSelectionOptions];
    }
    return _channelSelectionOptions;
}



@end
