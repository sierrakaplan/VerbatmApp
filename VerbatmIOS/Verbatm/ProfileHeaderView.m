//
//  ProfileHeaderView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 5/31/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel.h"

#import "Icons.h"

#import "Notifications.h"

#import "ParseBackendKeys.h"
#import <Parse/PFUser.h>
#import "ProfileHeaderView.h"
#import "ProfileInformationBar.h"

#import "SizesAndPositions.h"
#import "Styles.h"

#import "UIView+Effects.h"

@interface ProfileHeaderView() <ProfileInformationBarDelegate, UITextViewDelegate>

@property (nonatomic) PFUser *channelOwner;
@property (nonatomic) Channel *channel;
@property (nonatomic) BOOL isCurrentUser;
@property (nonatomic) ProfileInformationBar *userInformationBar;
@property (nonatomic) UILabel *userNameLabel;
@property (nonatomic) UILabel *blogTitle;
@property (nonatomic) UILabel *blogDescription;

@property (nonatomic) NSString * originalTitle;

// If this is the current user's profile, can go into edit mode
@property (nonatomic) BOOL editMode;
@property (nonatomic) UITextView *blogTitleEditable;
@property (nonatomic) UILabel *blogTitlePlaceholder;
@property (nonatomic) UITextView *blogDescriptionEditable;
@property (nonatomic) UILabel *blogDescriptionPlaceholder;

@property (nonatomic) UIButton * changeCoverPhoto;
@property (nonatomic) UIImageView * coverPhotoView;
@property (nonatomic) UIImageView * flippedCoverPhoto;
@property (nonatomic) UIView * coverView;

#define OFFSET_X 5.f
#define OFFSET_Y 10.f
#define USER_NAME_HEIGHT 15.f
#define BLOG_TITLE_HEIGHT 25.f
#define BLOG_DESCRIPTION_HEIGHT 90.f

#define USER_NAME_FONT_SIZE 15.f
#define BLOG_TITLE_FONT_SIZE 20.f
#define BLOG_DESCRIPTION_FONT_SIZE 16.f

#define TITLE_MAX_CHARACTERS 27.f
#define DESCRIPTION_MAX_CHARACTERS 250

#define COVER_PHOTO_HEIGHT 30.f
@end

@implementation ProfileHeaderView

-(instancetype)initWithFrame:(CGRect)frame andUser:(PFUser*)user
				  andChannel:(Channel*)channel inProfileTab:(BOOL) profileTab {
	self = [super initWithFrame:frame];
	if (self) {
		self.channelOwner = user ? user : [PFUser currentUser];
		self.channel = channel;
		self.isCurrentUser = (user == nil);
		self.editMode = NO;
		self.backgroundColor = [UIColor whiteColor];
		CGRect userInfoBarFrame = CGRectMake(0.f, 0.f, frame.size.width, PROFILE_INFO_BAR_HEIGHT);
		self.userInformationBar = [[ProfileInformationBar alloc] initWithFrame:userInfoBarFrame andUser:user
																	andChannel:channel inProfileTab:profileTab];
		self.userInformationBar.delegate = self;
		[self addSubview: self.userInformationBar];
		[self createLabels];
        [self checkForCoverPhoto];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(changeUserName)
													 name:NOTIFICATION_USERNAME_CHANGED_SUCCESFULLY
												   object:nil];
	}
	return self;
}

-(void) createLabels {
	CGRect userNameFrame = CGRectMake(OFFSET_X, self.userInformationBar.frame.origin.y +
									  self.userInformationBar.frame.size.height + OFFSET_Y,
									  self.frame.size.width - OFFSET_X*2, USER_NAME_HEIGHT);
	CGRect blogTitleFrame = CGRectMake(OFFSET_X, userNameFrame.origin.y + userNameFrame.size.height + OFFSET_Y,
									   self.frame.size.width - OFFSET_X*2, BLOG_TITLE_HEIGHT);
	CGRect blogDescriptionFrame = CGRectMake(OFFSET_X, blogTitleFrame.origin.y + blogTitleFrame.size.height + OFFSET_Y,
									   self.frame.size.width - OFFSET_X*2, BLOG_DESCRIPTION_HEIGHT);

	self.userNameLabel = [[UILabel alloc] initWithFrame: userNameFrame];
	self.userNameLabel.font = [UIFont fontWithName:REGULAR_FONT size:USER_NAME_FONT_SIZE];
	self.blogTitle = [[UILabel alloc] initWithFrame: blogTitleFrame];
	self.blogTitle.font = [UIFont fontWithName:BOLD_FONT size:BLOG_TITLE_FONT_SIZE];
	self.blogDescription = [[UILabel alloc] initWithFrame: blogDescriptionFrame];
	self.blogDescription.font = [UIFont fontWithName:ITALIC_FONT size:BLOG_DESCRIPTION_FONT_SIZE];
	self.blogDescription.lineBreakMode = NSLineBreakByWordWrapping;
	self.blogDescription.numberOfLines = 5;

	[self changeUserName];
	[self changeBlogTitle];
	[self changeBlogDescription];

	[self addSubview:self.userNameLabel];
	[self addSubview:self.blogTitle];
	[self addSubview:self.blogDescription];
    if(self.isCurrentUser)[self addChangeCoverPhotoButton];
}

-(void) changeUserName {
	NSString *newUserName = self.channelOwner[VERBATM_USER_NAME_KEY];
	self.userNameLabel.text = newUserName;
    [self.userNameLabel setTextColor:[UIColor whiteColor]];
}

-(void) changeBlogTitle {
	NSString *newTitle = self.channel.name;
	self.blogTitle.text = newTitle;
	[self.blogTitle sizeToFit];
    [self.blogTitle setTextColor:[UIColor whiteColor]];
}

-(void) changeBlogDescription {
	NSString *newDescription = self.channel.blogDescription;
	self.blogDescription.text = newDescription;
	[self.blogDescription sizeToFit];
    [self.blogDescription setTextColor:[UIColor whiteColor]];
//	CGFloat heightDiff = BLOG_DESCRIPTION_HEIGHT - self.blogDescription.frame.size.height - OFFSET_Y;
//	if (heightDiff < 0.f) heightDiff = 0.f;
//	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, PROFILE_HEADER_HEIGHT - heightDiff);
}




-(void)checkForCoverPhoto{
     [self.channel loadCoverPhotoWithCompletionBlock:^(UIImage * coverPhoto) {
       if(coverPhoto)[self setCoverPhotoImage:coverPhoto];
   }];
   
}

-(void)addChangeCoverPhotoButton {
      self.changeCoverPhoto = [[UIButton alloc] init];
      [self.changeCoverPhoto setImage:[UIImage imageNamed:ADD_COVER_PHOTO_ICON] forState:UIControlStateNormal];
       CGFloat coverPhotoIconWidth = (351 /106 ) *COVER_PHOTO_HEIGHT;
    
      self.changeCoverPhoto.frame = CGRectMake(self.frame.size.width - coverPhotoIconWidth, self.frame.size.width - COVER_PHOTO_HEIGHT,
                                                  +                                             coverPhotoIconWidth, COVER_PHOTO_HEIGHT);
      [self addSubview:self.changeCoverPhoto];
      [self.changeCoverPhoto addTarget:self action:@selector(coverPhotoButtonSelected) forControlEvents:UIControlEventTouchUpInside];
}

-(void)coverPhotoButtonSelected{
       [self.delegate presentGalleryToSelectImage];
}

-(void)setCoverPhotoImage:(UIImage *) coverPhotoImage{
    [self.coverPhotoView setImage:coverPhotoImage];
    self.coverPhotoView.contentMode = UIViewContentModeScaleAspectFit;
    [self.channel storeCoverPhoto:coverPhotoImage];
    [self insertSubview:self.coverView aboveSubview:self.coverPhotoView];
    [self.flippedCoverPhoto setImage:coverPhotoImage];
    self.flippedCoverPhoto.transform = CGAffineTransformMakeRotation(M_PI);
    [self.flippedCoverPhoto createBlurViewOnViewWithStyle:UIBlurEffectStyleExtraLight];
}

#pragma mark - Profile Info Bar Delegate methods -

// Only available in profile tab
-(void) settingsButtonSelected {
	[self.delegate settingsButtonClicked];
}

-(void) editButtonSelected {
	self.editMode = !self.editMode;
	if (self.editMode) {
        self.originalTitle = self.blogTitle.text;
		[self.blogTitle removeFromSuperview];
		[self.blogDescription removeFromSuperview];
		[self addSubview: self.blogTitleEditable];
		[self addSubview: self.blogDescriptionEditable];
		[self addSubviewsToTitle];
		[self addSubviewsToDescription];
		//self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, PROFILE_INFO_BAR_HEIGHT);
	} else {
        NSString * newTitle = ([self.blogTitleEditable.text isEqualToString:@""]) ? self.originalTitle: self.blogTitleEditable.text;
        [self.channel changeTitle:newTitle andDescription:self.blogDescriptionEditable.text];
		[self.blogTitleEditable removeFromSuperview];
		[self.blogDescriptionEditable removeFromSuperview];
		[self addSubview: self.blogTitle];
		[self addSubview: self.blogDescription];
		[self changeBlogTitle];
		[self changeBlogDescription];
	}
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {
    NSInteger length = textView.text.length + string.length - range.length;
    if (textView == self.blogTitleEditable) {
        return length <= TITLE_MAX_CHARACTERS;
        if(self.blogTitlePlaceholder){
             [self.blogTitlePlaceholder removeFromSuperview];
              self.blogTitlePlaceholder = nil;
           }

         return length <= TITLE_MAX_CHARACTERS;
    } else if (textView == self.blogDescriptionEditable) {
     
          if(self.blogDescriptionPlaceholder){
             [self.blogDescriptionPlaceholder removeFromSuperview];
             self.blogDescriptionPlaceholder = nil;
            }
        return length <= DESCRIPTION_MAX_CHARACTERS;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	if (textView == self.blogTitleEditable) {
		self.blogTitlePlaceholder.hidden = YES;
	} else if(textView == self.blogDescriptionEditable) {
		self.blogDescriptionPlaceholder.hidden = YES;
	}
}

- (void)textViewDidChange:(UITextView *)textView {
	if (textView == self.blogTitleEditable) {
		self.blogTitlePlaceholder.hidden = ([textView.text length] > 0);
	} else if(textView == self.blogDescriptionEditable) {
		self.blogDescriptionPlaceholder.hidden = ([textView.text length] > 0);
	}
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	if (textView == self.blogTitleEditable) {
		self.blogTitlePlaceholder.hidden = ([textView.text length] > 0);
	} else if(textView == self.blogDescriptionEditable) {
		self.blogDescriptionPlaceholder.hidden = ([textView.text length] > 0);
	}
}


-(void)followersButtonSelected{
    [self.delegate followersButtonSelected];
}
-(void)followingButtonSelected{
    [self.delegate followingButtonSelected];
}

-(void) backButtonSelected {
	[self.delegate exitCurrentProfile];
}

-(void) blockCurrentUserShouldBlock:(BOOL) shouldBlock {
	[self.delegate blockCurrentUserShouldBlock: shouldBlock];
}

#pragma mark - Lazy Instantiation -

-(UITextView *) blogTitleEditable {
    if (!_blogTitleEditable) {
        _blogTitleEditable = [[UITextView alloc] initWithFrame: CGRectMake(OFFSET_X, self.blogTitle.frame.origin.y,
                                                                           self.frame.size.width - OFFSET_X*2,
                                                                                       BLOG_TITLE_HEIGHT)];
            _blogTitleEditable.backgroundColor = [UIColor clearColor];
          _blogTitleEditable.layer.borderWidth = 0.5f;
       	_blogTitleEditable.layer.borderColor = [UIColor whiteColor].CGColor;
        _blogTitleEditable.layer.cornerRadius = 2.f;
        _blogTitleEditable.text = self.blogTitle.text;
        _blogTitleEditable.editable = YES;
        _blogTitleEditable.delegate = self;
       _blogTitleEditable.textColor = [UIColor whiteColor];
        _blogTitleEditable.font = [UIFont fontWithName:BOLD_FONT size:BLOG_TITLE_FONT_SIZE];
        _blogTitleEditable.textContainerInset = UIEdgeInsetsMake(0.f, 2.f, 0.f, 0.f);
        _blogTitleEditable.textContainer.lineFragmentPadding = 0;
        _blogTitleEditable.returnKeyType = UIReturnKeyDone;
    }
    return _blogTitleEditable;
}

-(UITextView *) blogDescriptionEditable {
	if (!_blogDescriptionEditable) {
		_blogDescriptionEditable = [[UITextView alloc] initWithFrame: CGRectMake(OFFSET_X, self.blogDescription.frame.origin.y,
																				 self.frame.size.width - OFFSET_X*2,
																				 BLOG_DESCRIPTION_HEIGHT)];
        _blogDescriptionEditable.backgroundColor = [UIColor clearColor];
    _blogDescriptionEditable.layer.borderWidth = 0.5f;
        _blogDescriptionEditable.layer.borderColor = [UIColor whiteColor].CGColor;
		_blogDescriptionEditable.layer.cornerRadius = 2.f;
		_blogDescriptionEditable.text = self.blogDescription.text;
		_blogDescriptionEditable.editable = YES;
		_blogDescriptionEditable.delegate = self;
		_blogDescriptionEditable.font = [UIFont fontWithName:ITALIC_FONT size:BLOG_DESCRIPTION_FONT_SIZE];
         _blogDescriptionEditable.textColor = [UIColor whiteColor];
		_blogDescriptionEditable.textContainerInset = UIEdgeInsetsMake(0.f, 2.f, 0.f, 0.f);
		_blogDescriptionEditable.textContainer.lineFragmentPadding = 0;
		_blogDescriptionEditable.returnKeyType = UIReturnKeyDone;
	}
	return _blogDescriptionEditable;
}

-(void) addSubviewsToDescription {
    UIImageView *editImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:EDIT_PINCHVIEW_ICON]];
    editImage.frame = CGRectMake(self.blogDescriptionEditable.frame.size.width - OFFSET_X - 20.f,
                                 self.blogDescriptionEditable.frame.size.height - OFFSET_X - 20.f,
                                 20.f, 20.f);
    [self.blogDescriptionEditable addSubview: editImage];
   [self.blogDescriptionEditable addSubview: self.blogDescriptionPlaceholder];
    if([self.blogDescriptionEditable.text isEqualToString:@""]){
        [self.blogDescriptionEditable addSubview: self.blogDescriptionPlaceholder];
    }
}

-(void) addSubviewsToTitle {
    UIImageView *editImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:EDIT_PINCHVIEW_ICON]];
    editImage.frame = CGRectMake(self.blogTitleEditable.frame.size.width - OFFSET_X - 20.f,
                                 self.blogTitleEditable.frame.size.height - OFFSET_X - 20.f,
                                 20.f, 20.f);
    [self.blogTitleEditable addSubview: editImage];
    [self.blogTitleEditable addSubview: self.blogTitlePlaceholder];
     if([self.blogTitleEditable.text isEqualToString:@""]){
       [self.blogTitleEditable addSubview: self.blogTitlePlaceholder];
    }
}

-(UILabel *) blogTitlePlaceholder {
	if (!_blogTitlePlaceholder) {
		_blogTitlePlaceholder = [[UILabel alloc] initWithFrame: CGRectMake(0.f, 0.f, self.frame.size.width, self.blogTitle.frame.size.height)];
		_blogTitlePlaceholder.font = [UIFont fontWithName:LIGHT_ITALIC_FONT size:BLOG_TITLE_FONT_SIZE];
		_blogTitlePlaceholder.text = @"tap here to title your blog!";
	}
	return _blogTitlePlaceholder;
}

-(UILabel *) blogDescriptionPlaceholder {
	if (!_blogDescriptionPlaceholder) {
        _blogDescriptionPlaceholder = [[UILabel alloc] initWithFrame: CGRectMake(0.f, 0.f, self.frame.size.width, self.blogDescription.frame.size.height)];
     	_blogDescriptionPlaceholder = [[UILabel alloc] initWithFrame: CGRectMake(2.f, 0.f, self.frame.size.width, self.blogDescriptionEditable.frame.size.height)];
        _blogDescriptionPlaceholder.font = [UIFont fontWithName:LIGHT_ITALIC_FONT size:BLOG_DESCRIPTION_FONT_SIZE];
        _blogDescriptionPlaceholder.text = @"tap here to add a blog description!";
        [_blogDescriptionPlaceholder setTextColor:[UIColor whiteColor]];
       _blogDescriptionPlaceholder.text = @"Tap here to add a blog description!";
	}
	return _blogDescriptionPlaceholder;
}
-(UIImageView *)coverPhotoView{
       if(!_coverPhotoView){
            _coverPhotoView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.frame.size.width,self.frame.size.width)];
               [self addSubview:_coverPhotoView];
               [self sendSubviewToBack:_coverPhotoView];
           }
      return _coverPhotoView;
}

-(UIImageView *)flippedCoverPhoto{
    if(!_flippedCoverPhoto){
        _flippedCoverPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, self.frame.size.width, self.frame.size.width,self.frame.size.width)];
        [self addSubview:_flippedCoverPhoto];
        [self sendSubviewToBack:_flippedCoverPhoto];
    }
    return _flippedCoverPhoto;
}
-(UIView *)coverView{
    if(!_coverView){
        _coverView = [[UIView alloc] initWithFrame: self.coverPhotoView.frame];
        _coverView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.5];
        [self insertSubview:_coverView aboveSubview:self.coverPhotoView];
    }
    return _coverView;
}

@end








