
//
//  v_multiplePhotoVideo.m
//  tester
//
//  Created by Iain Usiri on 12/20/14.
//  Copyright (c) 2014 IainAndLucio. All rights reserved.
//

#import "BaseArticleViewingExperience.h"
#import "CollectionPinchView.h"
#import "Durations.h"
#import "ImagePinchView.h"
#import "VideoPinchView.h"

#import "Notifications.h"

#import "PhotoAVE.h"
#import "PhotoVideoAVE.h"

#import "Styles.h"
#import "VideoAVE.h"

@interface PhotoVideoAVE() <UIScrollViewDelegate, PhotoAVETextEntryDelegate>

@property (strong, nonatomic) PhotoAVE* photosView;

@end
@implementation PhotoVideoAVE

-(id)initWithFrame:(CGRect)frame andPhotos:(NSArray*)photos andVideos:(NSArray*)videos orCollectionView:(CollectionPinchView *) collectionView
{
    self = [super initWithFrame:frame];
    if(self)
    {
		[self setBackgroundColor:[UIColor AVE_BACKGROUND_COLOR]];
        [self setSubViewsWithPhotos: photos andVideos:videos orPinchView:collectionView];
        //make sure the video is on repeat
        [self.videoView repeatVideoOnEnd:YES];
    }
    return self;
}

//sets the frames for the video view and the photo scrollview
-(void) setSubViewsWithPhotos: (NSArray*) photos andVideos: (NSArray*) videos orPinchView:(CollectionPinchView *) collection {
    
	float videoViewHeight = ((self.frame.size.width*3)/4);
	float photosViewHeight = (self.frame.size.height - videoViewHeight);

    CGRect videoViewFrame = CGRectMake(0, 0, self.frame.size.width, videoViewHeight);
    CGRect photoListFrame = CGRectMake(0, videoViewHeight, self.frame.size.width, photosViewHeight);
    
    
    self.photosView = [[PhotoAVE alloc] initWithFrame:photoListFrame andPhotoArray:photos orPinchview:(collection) ? collection : nil isSubViewOfPhotoVideoAve:YES];
    self.photosView.textEntrydelegate = self;
    self.videoView = [[VideoAVE alloc]initWithFrame:videoViewFrame pinchView:(collection.containsVideo) ? collection : nil orVideoArray:videos];

	[self addSubview:self.videoView];
	[self addSubview:self.photosView];

	
}


-(void) showAndRemoveCircle {
    if(self.povScrollView){
        self.photosView.povScrollView = self.povScrollView;
    }
    [self.photosView showAndRemoveCircle];
}


//image scroll view is on new page
-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//	NSInteger newPageIndex = scrollView.contentOffset.x/scrollView.frame.size.width;
}


#pragma mark -photo ave protocol-

-(void) editContentViewTextIsEditing{
    [self movePhotoAveUp:YES];
}
-(void) editContentViewTextDoneEditing{
    [self movePhotoAveUp:NO];
}


-(void)movePhotoAveUp:(BOOL) moveUp{
    if(moveUp){
        [UIView animateWithDuration:AVE_VIEW_FILLS_SCREEN_DURATION animations:^{
            [self bringSubviewToFront:self.photosView];
            self.photosView.frame = CGRectMake(0, 0, self.photosView.frame.size.width, self.photosView.frame.size.height);
        }];
    }else{
        [UIView animateWithDuration:AVE_VIEW_FILLS_SCREEN_DURATION animations:^{
            self.photosView.frame = CGRectMake(0, self.videoView.frame.size.height, self.photosView.frame.size.width, self.photosView.frame.size.height);
        }];
        
    }
}



#pragma mark -managing content viewing-

-(void)offScreen {
    [self.videoView offScreen];
    [self.photosView offScreen];
}

-(void)onScreen {
    [self.videoView onScreen];
}

/*Mute the video*/
-(void)mutePlayer {
	[self.videoView muteVideo];
}

/*Enable's the sound on the video*/
-(void)enableSound{
    [self.videoView unmuteVideo];
}
-(void)almostOnScreen{
    [self.videoView almostOnScreen];
}


@end
