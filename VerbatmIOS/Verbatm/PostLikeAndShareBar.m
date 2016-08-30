//
//  PostLikeAndShareBar.m
//  Verbatm
//
//  Created by Iain Usiri on 12/29/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//


#import "Icons.h"
#import "PostLikeAndShareBar.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "Like_BackendManager.h"

@interface PostLikeAndShareBar ()

@property (nonatomic,strong) UIButton *likeButton;
@property (nonatomic,strong) UIButton *numLikesButton;

@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *delete_Or_FlagButton;
@property (nonatomic,strong) UIButton *numSharesButton;
@property (nonatomic, strong) UILabel *pageNumberLabel;

@property (nonatomic, strong) UIButton *commentButon;
@property (nonatomic, strong) UIButton * numCommentsButton;



@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic) BOOL isMuted;

@property (strong, nonatomic) UIImage *likeButtonNotLikedImage;
@property (strong, nonatomic) UIImage *likeButtonLikedImage;

@property (nonatomic) BOOL isLiked;

@property (nonatomic) NSNumber * totalNumberOfPages;

@property (nonatomic) NSNumber * totalNumberOfLikes;//number of likes on our related AVE
@property (nonatomic) NSNumber * totalNumberOfComments;//number of comments on our related AVE



@property (nonatomic) NSDictionary * likeNumberTextAttributes;

#define NUMBER_FONT_SIZE 10.f
#define ICON_SPACING_GAP 5.f
#define NUMBER_TEXT_FONT CHANNEL_TAB_BAR_FOLLOWERS_FONT
#define NUMBER_TEXT_FONT_SIZE 25.f

#define OF_TEXT_FONT CHANNEL_TAB_BAR_FOLLOWERS_FONT
#define OF_TEXT_FONT_SIZE 18.f

#define BIG_ICON_SPACING 18.f
#define BIG_ICON_SIZE (self.frame.size.width - (BIG_ICON_SPACING*2))

#define DELETE_FLAG_BUTTON_HEIGHT (self.frame.size.width - (ICON_SPACING_GAP*3.f))
#define DELETE_FLAG_BUTTON_Y  (self.frame.size.height - DELETE_FLAG_BUTTON_HEIGHT - ICON_SPACING_GAP - 10.f)

@end

@implementation PostLikeAndShareBar

-(instancetype) initWithFrame:(CGRect)frame numberOfLikes:(NSNumber *) numLikes numberOfShares:(NSNumber *) numShares numComments:(NSNumber *) numComments numberOfPages:(NSNumber *) numPages andStartingPageNumber:(NSNumber *) startPage {
    
    self = [super initWithFrame:frame];
    if(self){
        
        [self creatButtonsWithNumLike:numLikes numComments:numComments andNumShare:numShares];
        self.totalNumberOfPages = numPages;
        self.totalNumberOfLikes = numLikes;
        self.totalNumberOfComments = numComments;
        [self formatView];
        self.isMuted = NO;
    }
    return self;
}


-(void)formatView{
    self.backgroundColor = LIKE_SHARE_BAR_BACKGROUND_COLOR;
    self.layer.cornerRadius = 10.f;
}

-(void) createCounterLabelStartingAtPage:(NSNumber *) startPage outOf:(NSNumber *) totalPages{
    NSAttributedString * pageCounterText = [self createCounterStringStartingAtPage:startPage outOf:totalPages];
    CGRect labelFrame = CGRectMake(self.frame.size.width - ICON_SPACING_GAP - pageCounterText.size.width, 0.f,
								   self.frame.size.height, self.frame.size.height);
    
    self.pageNumberLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [self.pageNumberLabel setAttributedText:pageCounterText];
    [self addSubview:self.pageNumberLabel];
}

//creates the text for the numbers at the bottom right that show what page you're on and how
//many there are left
-(NSAttributedString *) createCounterStringStartingAtPage:(NSNumber *) startPage outOf:(NSNumber *) totalPages{
    //create attributed string of number of pages
    NSDictionary * numberTextAttributes =@{
                                              NSForegroundColorAttributeName: [UIColor whiteColor],
                                              NSFontAttributeName: [UIFont fontWithName:NUMBER_TEXT_FONT size:NUMBER_TEXT_FONT_SIZE]};
    
    
    NSMutableAttributedString * pageWeAreOn = [[NSMutableAttributedString alloc] initWithString:startPage.stringValue attributes:numberTextAttributes];
    
    NSAttributedString * totalNumberOfPages = [[NSMutableAttributedString alloc] initWithString:totalPages.stringValue attributes:numberTextAttributes];
    
    //the small "of" word between numbers. eg 1of5
    NSDictionary * ofTextAttributes =@{
                                           NSForegroundColorAttributeName: [UIColor whiteColor],
                                           NSFontAttributeName: [UIFont fontWithName:OF_TEXT_FONT size:OF_TEXT_FONT_SIZE]};
    
    NSMutableAttributedString * ofText = [[NSMutableAttributedString alloc] initWithString:@"of" attributes:ofTextAttributes];
    
    [pageWeAreOn appendAttributedString:ofText];
    [pageWeAreOn appendAttributedString:totalNumberOfPages];
    return pageWeAreOn;
}

-(void) creatButtonsWithNumLike:(NSNumber *) numLikes numComments:(NSNumber *)numComments andNumShare:(NSNumber *) numShares {
    
    if(!numComments){
        numComments = @(0);
    }
    
    [self createCommentButtonNumbers:numComments];
    [self createCommentButton];
    
    if (numLikes && numLikes.integerValue >= 0) {
        [self createLikeButtonNumbers:numLikes];
    }else{
        [self createLikeButtonNumbers:@(0)];
    }
    [self createLikeButton];
    if (numShares && numShares.integerValue >= 0) {
        [self createShareButtonNumbers:numShares];
    }else{
        [self createShareButtonNumbers:@(0)];
    }
    [self createShareButton];
   
	
}

-(void)createShareButton {
    //create share button
    CGRect shareButtonFrame = CGRectMake(ICON_SPACING_GAP,
                                         self.numSharesButton.frame.origin.y - (DELETE_FLAG_BUTTON_HEIGHT + BIG_ICON_SPACING),
                                         DELETE_FLAG_BUTTON_HEIGHT, DELETE_FLAG_BUTTON_HEIGHT);
    
    self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.shareButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.shareButton setFrame:shareButtonFrame];
	//todo: this is a hack until we get a better like icon from Aish
	[self.shareButton setImageEdgeInsets:UIEdgeInsetsMake(3.f, 3.f, 3.f, 3.f)];
    [self.shareButton setImage:[UIImage imageNamed:SHARE_ICON] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchDown];
    
    [self addSubview:self.shareButton];
}

-(void)createLikeButton {
    CGRect likeButtonFrame =  CGRectMake(ICON_SPACING_GAP,
										self.numLikesButton.frame.origin.y - (DELETE_FLAG_BUTTON_HEIGHT + BIG_ICON_SPACING),
                                         DELETE_FLAG_BUTTON_HEIGHT, DELETE_FLAG_BUTTON_HEIGHT);
    
    self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.likeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.likeButton setFrame:likeButtonFrame];
    self.likeButtonLikedImage = [UIImage imageNamed:LIKE_ICON_PRESSED];
    self.likeButtonNotLikedImage = [UIImage imageNamed:LIKE_ICON_UNPRESSED];
    [self.likeButton setImage:self.likeButtonNotLikedImage forState:UIControlStateNormal];
    [self.likeButton addTarget:self action:@selector(likeButtonPressed) forControlEvents:UIControlEventTouchDown];
    
    [self addSubview:self.likeButton];
}

-(void)createCommentButton{
    CGRect commentButtonFrame =  CGRectMake(ICON_SPACING_GAP,
                                         self.numCommentsButton.frame.origin.y - (DELETE_FLAG_BUTTON_HEIGHT + BIG_ICON_SPACING),
                                         DELETE_FLAG_BUTTON_HEIGHT, DELETE_FLAG_BUTTON_HEIGHT);
    
    self.commentButon = [UIButton buttonWithType:UIButtonTypeCustom];
    self.commentButon.contentMode = UIViewContentModeScaleAspectFit;
    [self.commentButon setFrame:commentButtonFrame];
    [self.commentButon setImage:[UIImage imageNamed:COMMENT_ICON] forState:UIControlStateNormal];
    [self.commentButon addTarget:self action:@selector(numCommentsButtonSelected) forControlEvents:UIControlEventTouchDown];
    
    [self addSubview:self.commentButon];
}

-(void)presentMuteButton:(BOOL) shouldPresent{
	if(shouldPresent){
		[self addSubview:self.muteButton];
	}else{
		[self.muteButton removeFromSuperview];
		self.muteButton = nil;
	}
}

-(void)createLikeButtonNumbers:(NSNumber *) numLikes {
    if(self.numLikesButton){
        [self.numLikesButton removeFromSuperview];
        self.numLikesButton = nil;
    }
    self.numLikesButton = [UIButton buttonWithType:UIButtonTypeCustom];

	NSString *likesText = numLikes.integerValue > 1 ? @" likes" : @" like";
    NSAttributedString * followersText = [[NSAttributedString alloc] initWithString:[numLikes.stringValue stringByAppendingString:likesText] attributes:self.likeNumberTextAttributes];
    [self.numLikesButton setAttributedTitle:followersText forState:UIControlStateNormal];
    CGSize textSize = [[numLikes.stringValue stringByAppendingString:likesText] sizeWithAttributes:self.likeNumberTextAttributes];
    
    CGRect likeNumberButtonFrame = CGRectMake((self.frame.size.width - textSize.width)/2.f,
                                              self.commentButon.frame.origin.y - (BIG_ICON_SPACING + textSize.height),
                                              textSize.width, textSize.height);
    
    [self.numLikesButton setFrame:likeNumberButtonFrame];
    
    
    [self.numLikesButton addTarget:self action:@selector(numLikesButtonSelected) forControlEvents:UIControlEventTouchDown];
    
    [self addSubview:self.numLikesButton];
}


-(void)createCommentButtonNumbers:(NSNumber *) numComments {
    if(self.numCommentsButton){
        [self.numCommentsButton removeFromSuperview];
        self.numCommentsButton = nil;
    }
    self.numCommentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    NSString * commentsText = numComments.integerValue > 1 ? @" comm" : @" comms";
    
    NSAttributedString * commentAttrText = [[NSAttributedString alloc] initWithString:[numComments.stringValue stringByAppendingString:commentsText] attributes:self.likeNumberTextAttributes];
    
    [self.numCommentsButton setAttributedTitle:commentAttrText forState:UIControlStateNormal];
    
    CGSize textSize = [[numComments.stringValue stringByAppendingString:commentsText] sizeWithAttributes:self.likeNumberTextAttributes];
    
    CGRect likeNumberButtonFrame = CGRectMake((self.frame.size.width - textSize.width)/2.f,
                                              DELETE_FLAG_BUTTON_Y - (BIG_ICON_SPACING + textSize.height),
                                              textSize.width, textSize.height);
    [self.numCommentsButton setFrame:likeNumberButtonFrame];
    
    
    [self.numCommentsButton addTarget:self action:@selector(numCommentsButtonSelected) forControlEvents:UIControlEventTouchDown];
    
    [self addSubview:self.numCommentsButton];
}


-(void)createShareButtonNumbers:(NSNumber *) numShares {
    if(self.numSharesButton){
        [self.numSharesButton removeFromSuperview];
        self.numSharesButton = nil;
    }
    self.numSharesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    NSString *likesText = numShares.integerValue > 1 ? @" shares" : @" share";
    NSAttributedString * followersText = [[NSAttributedString alloc] initWithString:[numShares.stringValue stringByAppendingString:likesText] attributes:self.likeNumberTextAttributes];
    [self.numSharesButton setAttributedTitle:followersText forState:UIControlStateNormal];
    CGSize textSize = [[numShares.stringValue stringByAppendingString:likesText] sizeWithAttributes:self.likeNumberTextAttributes];
    
    CGRect shareNumberButtonFrame = CGRectMake((self.frame.size.width - textSize.width)/2.f,
											  self.likeButton.frame.origin.y - (BIG_ICON_SPACING + textSize.height),
                                              textSize.width, textSize.height);
    [self.numSharesButton setFrame:shareNumberButtonFrame];

    [self.numSharesButton addTarget:self action:@selector(numSharesButtonSelected) forControlEvents:UIControlEventTouchDown];
    
    [self addSubview:self.numSharesButton];
}

-(void)shouldStartPostAsLiked:(BOOL) postLiked{
    if(postLiked){
        [self.likeButton setImage:self.likeButtonLikedImage  forState:UIControlStateNormal];
        self.isLiked = YES;
        
    } else {
        [self.likeButton setImage:self.likeButtonNotLikedImage forState:UIControlStateNormal];
        self.isLiked = NO;
    }
}
-(void)incrementComments{
    self.totalNumberOfComments = [NSNumber numberWithInteger:([self.totalNumberOfComments integerValue] +1) ];
    [self createCommentButtonNumbers:self.totalNumberOfComments];
}


-(void)createDeleteButton {
    [self createDeleteOrFlagButtonIsFlag:NO];
}

-(void) createFlagButton {
    [self createDeleteOrFlagButtonIsFlag:YES];
}

-(void)createDeleteOrFlagButtonIsFlag:(BOOL) flag {
    UIImage * buttonImage;
    if(flag) {
        buttonImage = [UIImage imageNamed:FLAG_POST_ICON ];
    } else {
        buttonImage = [UIImage imageNamed:DELETE_POST_ICON];
    }

    CGRect deleteButtonFrame = CGRectMake(ICON_SPACING_GAP,DELETE_FLAG_BUTTON_Y,
										  DELETE_FLAG_BUTTON_HEIGHT, DELETE_FLAG_BUTTON_HEIGHT);
    self.delete_Or_FlagButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.delete_Or_FlagButton setFrame:deleteButtonFrame];
    [self.delete_Or_FlagButton setImage:buttonImage forState:UIControlStateNormal];
    [self.delete_Or_FlagButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
	if (flag) [self.delete_Or_FlagButton setImageEdgeInsets:UIEdgeInsetsMake(1.f, 1.f, 1.f, 1.f)];
    [self.delete_Or_FlagButton addTarget:self action:
     (flag) ? @selector(flagButtonPressed):@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchDown];
    [self addSubview:self.delete_Or_FlagButton];
}

#pragma mark - Button actions -


//the icon is selected
-(void)shareButtonPressed{
    [self.delegate userAction:Share isPositive:YES];
}

//the icon is selected
-(void) likeButtonPressed {
    if(self.isLiked){
        [self.likeButton setImage:self.likeButtonNotLikedImage forState:UIControlStateNormal];
        self.isLiked = NO;
    }else{
        [self.likeButton setImage: self.likeButtonLikedImage forState:UIControlStateNormal];
        self.isLiked = YES;
    }
    
    [self changeLikeCount:self.isLiked];
    
    [self.delegate userAction:Like isPositive:self.isLiked];
}

-(void)muteButtonPressed {
	if(self.isMuted){
		self.isMuted = false;
		[self.muteButton setImage:[UIImage imageNamed:UNMUTED_ICON] forState:UIControlStateNormal];
	}else{
		self.isMuted = true;
		[self.muteButton  setImage:[UIImage imageNamed:MUTED_ICON] forState:UIControlStateNormal];
	}
	[self.delegate muteButtonSelected:self.isMuted];
}

-(void)deleteButtonPressed {
	[self.delegate deleteButtonPressed];
}

-(void)flagButtonPressed{
    [self.delegate flagButtonPressed];
}

-(void)changeLikeCount:(BOOL)up{
    NSInteger currentLikes = self.totalNumberOfLikes.integerValue;
    if(up) {
        currentLikes= 1+currentLikes;
    } else {
        currentLikes = currentLikes -1;
        if(currentLikes < 0) currentLikes = 0;
    }
    self.totalNumberOfLikes = [NSNumber numberWithInteger:currentLikes];
    [self createLikeButtonNumbers: self.totalNumberOfLikes];
	
}

#pragma mark - Display likes and shares -

//the actual number view is selected
-(void) numLikesButtonSelected {
    [self.delegate showWhoLikesThePost];
}

-(void) numCommentsButtonSelected {
    [self.delegate showWhoCommentedOnthePost];
}

//todo:
//the actual number view is selected
-(void) numSharesButtonSelected {
    
}

#pragma mark - Lazy instantiation -

-(NSDictionary *)likeNumberTextAttributes{
    if(!_likeNumberTextAttributes){
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        _likeNumberTextAttributes =@{
                           NSForegroundColorAttributeName: [UIColor whiteColor],
                           NSParagraphStyleAttributeName:paragraphStyle,
                           NSFontAttributeName: [UIFont fontWithName:CHANNEL_TAB_BAR_FOLLOWERS_FONT size:NUMBER_FONT_SIZE]};
    }
    
    return _likeNumberTextAttributes;
}

-(UIButton *)muteButton{
    if(!_muteButton){
        _muteButton = [[UIButton alloc] init];

		CGFloat size = self.frame.size.height - (ICON_SPACING_GAP*2);
		UIView *rightView = self.numLikesButton ? self.numLikesButton : self.likeButton;
        CGRect buttonFrame = CGRectMake(rightView.frame.origin.x + rightView.frame.size.width + ICON_SPACING_GAP,
										ICON_SPACING_GAP, size, size);
        _muteButton.frame = buttonFrame;
        
        [_muteButton setImage:[UIImage imageNamed:UNMUTED_ICON] forState:UIControlStateNormal];
        [_muteButton addTarget:self action:@selector(muteButtonPressed) forControlEvents:UIControlEventTouchDown];
    }
    return _muteButton;
}

@end
