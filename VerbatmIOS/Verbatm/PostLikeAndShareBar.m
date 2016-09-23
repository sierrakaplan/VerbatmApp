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

@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic,strong) UIButton *numSharesButton;

@property (nonatomic) NSDictionary * likeNumberTextAttributes;
@property (nonatomic,strong) UIButton *likeButton;
@property (nonatomic,strong) UIButton *numLikesButton;
@property (strong, nonatomic) UIImage *likeButtonNotLikedImage;
@property (strong, nonatomic) UIImage *likeButtonLikedImage;
@property (nonatomic) BOOL isLiked;

@property (nonatomic, strong) UIButton *commentButon;
@property (nonatomic, strong) UIButton *numCommentsButton;

@property (nonatomic, strong) UIButton *delete_Or_FlagButton;

@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic) BOOL isMuted;

@property (nonatomic) NSNumber *totalNumberOfPages;
@property (nonatomic) NSNumber *numberOfShares;
@property (nonatomic) NSNumber *numberOfLikes;
@property (nonatomic) NSNumber *numberOfComments;

#define NUMBER_FONT_SIZE 10.f
#define COMMENT_TEXT_SIZE 8.f
#define ICON_SPACING_GAP ((self.frame.size.width - BIG_ICON_SIZE)/2.f)
#define NUMBER_TEXT_FONT CHANNEL_TAB_BAR_FOLLOWERS_FONT
#define NUMBER_TEXT_FONT_SIZE 25.f

#define OF_TEXT_FONT CHANNEL_TAB_BAR_FOLLOWERS_FONT
#define OF_TEXT_FONT_SIZE 18.f

#define BIG_ICON_SPACING 5.f
#define BIG_ICON_SIZE 30.f

@end

@implementation PostLikeAndShareBar

-(instancetype) initWithFrame:(CGRect)frame
				numberOfLikes:(NSNumber *)numLikes
			   numberOfShares:(NSNumber *)numShares
				  numComments:(NSNumber *)numComments
				numberOfPages:(NSNumber *)numPages
		andStartingPageNumber:(NSNumber *)startPage {
    
    self = [super initWithFrame:frame];
    if(self) {
		self.totalNumberOfPages = numPages ? numPages : [NSNumber numberWithInteger:1];
		self.numberOfShares = numShares ? numShares : [NSNumber numberWithInteger:0];
        self.numberOfLikes = numLikes ? numLikes : [NSNumber numberWithInteger:0];
        self.numberOfComments = numComments ? numComments : [NSNumber numberWithInteger:0];

		self.backgroundColor = LIKE_SHARE_BAR_BACKGROUND_COLOR;
		self.layer.cornerRadius = 10.f;
        self.isMuted = NO;

		[self addSubview: self.shareButton];
		[self addSubview: self.numSharesButton];
		[self addSubview: self.likeButton];
		[self addSubview: self.numLikesButton];
		[self addSubview: self.commentButon];
		[self addSubview: self.numCommentsButton];
		[self addSubview: self.delete_Or_FlagButton];
    }
    return self;
}

-(void)presentMuteButton:(BOOL) shouldPresent{
	if(shouldPresent){
		[self addSubview:self.muteButton];
	} else {
		[self.muteButton removeFromSuperview];
		self.muteButton = nil;
	}
}

-(UIButton*) shareButton {
	if (!_shareButton) {
		CGRect shareButtonFrame = CGRectMake(ICON_SPACING_GAP, ICON_SPACING_GAP,
											 BIG_ICON_SIZE, BIG_ICON_SIZE);
		_shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_shareButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
		[_shareButton setFrame:shareButtonFrame];
		//todo: this is a hack until we get a better like icon from Aish
		[_shareButton setImageEdgeInsets:UIEdgeInsetsMake(3.f, 3.f, 3.f, 3.f)];
		[_shareButton setImage:[UIImage imageNamed:SHARE_ICON] forState:UIControlStateNormal];
		[_shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchDown];
	}
	return _shareButton;
}

-(UIButton*)numSharesButton {
	if (!_numSharesButton) {
		_numSharesButton = [UIButton buttonWithType:UIButtonTypeCustom];

		CGRect shareNumberButtonFrame = CGRectMake(0.f, self.shareButton.frame.origin.y + self.shareButton.frame.size.height,
												   self.frame.size.width, BIG_ICON_SIZE);
		[_numSharesButton setFrame:shareNumberButtonFrame];
		[_numSharesButton addTarget:self action:@selector(numSharesButtonSelected) forControlEvents:UIControlEventTouchDown];
		[self setNumberOfShares];
	}
	return _numSharesButton;
}

-(UIButton*)likeButton {
	if (!_likeButton) {
		CGRect likeButtonFrame =  CGRectMake(ICON_SPACING_GAP,
											 self.numSharesButton.frame.origin.y + self.numSharesButton.frame.size.height,
											 BIG_ICON_SIZE, BIG_ICON_SIZE);
		_likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_likeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
		[_likeButton setFrame:likeButtonFrame];
		self.likeButtonLikedImage = [UIImage imageNamed:LIKE_ICON_PRESSED];
		self.likeButtonNotLikedImage = [UIImage imageNamed:LIKE_ICON_UNPRESSED];
		[_likeButton setImage:self.likeButtonNotLikedImage forState:UIControlStateNormal];
		[_likeButton addTarget:self action:@selector(likeButtonPressed) forControlEvents:UIControlEventTouchDown];
	}
	return _likeButton;
}

-(UIButton*) numLikesButton {
	if (!_numLikesButton) {
		_numLikesButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_numLikesButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		CGRect likeNumberButtonFrame = CGRectMake(0.f, self.likeButton.frame.origin.y + self.likeButton.frame.size.height,
												  self.frame.size.width, BIG_ICON_SIZE);

		[_numLikesButton setFrame:likeNumberButtonFrame];
		[_numLikesButton addTarget:self action:@selector(numLikesButtonSelected) forControlEvents:UIControlEventTouchDown];
		[self setNumberOfLikes];
	}
	return _numLikesButton;
}

-(UIButton*)commentButon {
	if (!_commentButon) {
		CGRect commentButtonFrame =  CGRectMake(ICON_SPACING_GAP, self.numLikesButton.frame.origin.y +
												self.numLikesButton.frame.size.height, BIG_ICON_SIZE, BIG_ICON_SIZE);

		_commentButon = [UIButton buttonWithType:UIButtonTypeCustom];
		_commentButon.contentMode = UIViewContentModeScaleAspectFit;
		[_commentButon setFrame:commentButtonFrame];
		[_commentButon setImage:[UIImage imageNamed:COMMENT_ICON] forState:UIControlStateNormal];
		[_commentButon addTarget:self action:@selector(numCommentsButtonSelected) forControlEvents:UIControlEventTouchDown];
	}
	return _commentButon;
}

-(UIButton*)numCommentsButton {
	if (!_numCommentsButton) {
		_numCommentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		CGRect commentTextFrame = CGRectMake(0.f, self.commentButon.frame.origin.y + self.commentButon.frame.size.height,
											 self.frame.size.width, BIG_ICON_SIZE);
		[_numCommentsButton setFrame: commentTextFrame];
		[_numCommentsButton addTarget:self action:@selector(numCommentsButtonSelected) forControlEvents:UIControlEventTouchDown];
		[self setNumberOfComments];
	}
	return _numCommentsButton;
}

-(void)shouldStartPostAsLiked:(BOOL) postLiked {
    if(postLiked) {
        [self.likeButton setImage:self.likeButtonLikedImage forState:UIControlStateNormal];
        self.isLiked = YES;
    } else {
        [self.likeButton setImage:self.likeButtonNotLikedImage forState:UIControlStateNormal];
        self.isLiked = NO;
    }
}

-(void)incrementComments {
    self.numberOfComments = [NSNumber numberWithInteger:([self.numberOfComments integerValue]+1)];
    [self setNumberOfComments];
}

-(void) setNumberOfShares {
	NSString *sharesText = self.numberOfShares.integerValue > 1 ? @" shares" : @" share";
	NSAttributedString *numberOfSharesText = [[NSAttributedString alloc] initWithString:[self.numberOfShares.stringValue
																						 stringByAppendingString:sharesText]
																			 attributes:self.likeNumberTextAttributes];
	[_numSharesButton setAttributedTitle:numberOfSharesText forState:UIControlStateNormal];
}

-(void) setNumberOfLikes {
	NSString *likesText = self.numberOfLikes.integerValue > 1 ? @" likes" : @" like";
	NSAttributedString *numberOfLikesText = [[NSAttributedString alloc] initWithString:[self.numberOfLikes.stringValue
																						stringByAppendingString:likesText]
																			attributes:self.likeNumberTextAttributes];
	[_numLikesButton setAttributedTitle:numberOfLikesText forState:UIControlStateNormal];
}

-(void) setNumberOfComments {
	NSString *commentsText = self.numberOfComments.integerValue != 1 ? @" comments" : @" comment";
	NSMutableDictionary *textAttributes = [NSMutableDictionary dictionaryWithDictionary:self.likeNumberTextAttributes];
	textAttributes[NSFontAttributeName] = [UIFont fontWithName:CHANNEL_TAB_BAR_FOLLOWERS_FONT size:COMMENT_TEXT_SIZE];
	NSAttributedString *numberOfCommentsText = [[NSAttributedString alloc] initWithString:[self.numberOfComments.stringValue
																						   stringByAppendingString:commentsText] attributes: textAttributes];
	[_numCommentsButton setAttributedTitle:numberOfCommentsText forState:UIControlStateNormal];
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

    CGRect deleteButtonFrame = CGRectMake(ICON_SPACING_GAP, self.numCommentsButton.frame.origin.y +
										  self.numCommentsButton.frame.size.height,
										  BIG_ICON_SIZE, BIG_ICON_SIZE);
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

-(void)changeLikeCount:(BOOL)up {
    NSInteger currentLikes = self.numberOfLikes.integerValue;
    if(up) {
        currentLikes = currentLikes+1;
    } else {
        currentLikes = currentLikes-1;
        if(currentLikes<0) currentLikes = 0;
    }
    self.numberOfLikes = [NSNumber numberWithInteger:currentLikes];
    [self setNumberOfLikes];
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
