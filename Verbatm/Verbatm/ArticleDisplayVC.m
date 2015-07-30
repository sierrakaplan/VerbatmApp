//
//  verbatmArticleDisplayCV.m
//  Verbatm
//
//  Created by Iain Usiri on 6/17/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ArticleDisplayVC.h"
#import "TextAVE.h"
#import "BaseArticleViewingExperience.h"
#import "AVETypeAnalyzer.h"
#import "Page.h"
#import "Article.h"
#import "VideoAVE.h"
#import "BaseArticleViewingExperience.h"
#import "MultiplePhotoVideoAVE.h"
#import "UIEffects.h"
#import "Notifications.h"
#import "Icons.h"
#import "Durations.h"
#import "Strings.h"
#import "Styles.h"
#import "SizesAndPositions.h"
#import "UIView+Glow.h"

@interface ArticleDisplayVC () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSMutableArray * Objects;//either pinchObjects or Pages
@property (strong, nonatomic) NSMutableArray* poppedOffPages;
@property (strong, nonatomic) UIView* animatingView;
@property (strong, nonatomic) UIScrollView* scrollView;
@property (strong, nonatomic) UIPanGestureRecognizer* panGesture;
@property (nonatomic) CGPoint lastPoint;
@property (atomic, strong) UIActivityIndicatorView *activityIndicator;

//The first object in the list will be the last to be shown in the Article
@property (strong, nonatomic) NSMutableArray* pageAVEs;
@property (weak, nonatomic) IBOutlet UIButton *exitArticleButton;
@property (strong, nonatomic) UIButton* publishButton;
//saves the prev point for the exit (pan) gesture
@property (nonatomic) CGPoint previousGesturePoint;
@property (nonatomic) CGRect scrollViewRestingFrame;
@property (nonatomic) CGRect publishButtonRestingFrame;
@property (nonatomic) CGRect publishButtonFrame;
@property (nonatomic) NSAttributedString *publishButtonTitle;
@property (nonatomic) float pageScrollTopBottomArea;

//the amount of space that must be pulled to exit
#define EXIT_EPSILON 60
@end

@implementation ArticleDisplayVC
@synthesize poppedOffPages = _poppedOffPages;
@synthesize animatingView = _animatingView;
@synthesize lastPoint = _lastPoint;

#pragma mark - View loading

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showArticle:) name:NOTIFICATION_SHOW_ARTICLE object: nil];
	float middleScreenSize = (self.view.frame.size.height/CIRCLE_OVER_IMAGES_RADIUS_FACTOR_OF_HEIGHT)*2 + TOUCH_THRESHOLD*2;
	self.pageScrollTopBottomArea = (self.view.frame.size.height - middleScreenSize)/2.f;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)setpageAVEs:(NSMutableArray *)pageAVEs {
	_pageAVEs = pageAVEs;
}

//make sure to stop all videos
-(void)cleanUp {
	if (!self.pageAVEs) return;
	for (UIView* ave in self.pageAVEs) {
		if([ave isKindOfClass:[BaseArticleViewingExperience class]]) {
			[self stopVideosInView:[(BaseArticleViewingExperience*)ave subAVE]];
		} else {
			[self stopVideosInView:ave];
		}
	}
}

-(void) stopVideosInView:(UIView*) view {
	if ([view isKindOfClass:[VideoAVE class]]) {
		[(VideoAVE*)view stopVideo];
	} else if([view isKindOfClass:[MultiplePhotoVideoAVE class]]) {
		[[(MultiplePhotoVideoAVE*)view videoView] stopVideo];
	}
}

-(void)startActivityIndicator {
    //add animation indicator here
    //Create and add the Activity Indicator to splashView
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.alpha = 1.0;
    self.activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    self.activityIndicator.hidesWhenStopped = YES;
    [self.scrollView addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

-(void)stopActivityIndicator {
    [self.activityIndicator stopAnimating];
}


-(void) publishArticleButtonPressed: (UIButton*)sender {
	[self showScrollView:NO];
	[self cleanUp];
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PUBLISH_ARTICLE
														object:nil
													  userInfo:nil];
}

-(void)setUpScrollView {
	self.scrollViewRestingFrame = CGRectMake(self.view.frame.size.width, 0,  self.view.frame.size.width, self.view.frame.size.height);
    if(self.scrollView) {
        //this means that we have already used this scrollview to present another article
        //so we want to clear it and then exit
        for(UIView * page in self.scrollView.subviews) [page removeFromSuperview];
    }else{
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.frame = self.scrollViewRestingFrame;
        [self.view addSubview: self.scrollView];
        self.scrollView.pagingEnabled = YES;
		self.scrollView.scrollEnabled = YES;
        [self.scrollView setShowsVerticalScrollIndicator:NO];
        [self.scrollView setShowsHorizontalScrollIndicator:NO];
        self.scrollView.bounces = NO;
        self.scrollView.backgroundColor = [UIColor whiteColor];
        [UIEffects addShadowToView:self.scrollView];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, [self.pageAVEs count]*self.view.frame.size.height);
}

-(void) addPublishButton {
	self.publishButtonFrame = CGRectMake(self.view.frame.size.width - PUBLISH_BUTTON_XOFFSET - PUBLISH_BUTTON_SIZE, PUBLISH_BUTTON_YOFFSET, PUBLISH_BUTTON_SIZE, PUBLISH_BUTTON_SIZE);
	self.publishButtonRestingFrame = CGRectMake(self.view.frame.size.width, PUBLISH_BUTTON_YOFFSET, PUBLISH_BUTTON_SIZE, PUBLISH_BUTTON_SIZE);

	self.publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.publishButton setFrame:self.publishButtonRestingFrame];
	[self.publishButton setBackgroundImage:[UIImage imageNamed:PUBLISH_BUTTON_IMAGE] forState:UIControlStateNormal];

	UIColor *labelColor = [UIColor PUBLISH_BUTTON_LABEL_COLOR];
	UIFont* labelFont = [UIFont fontWithName:BUTTON_FONT size:PUBLISH_BUTTON_LABEL_FONT_SIZE];
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowBlurRadius:PUBLISH_BUTTON_LABEL_SHADOW_BLUR_RADIUS];
	[shadow setShadowColor:labelColor];
	[shadow setShadowOffset:CGSizeMake(0, PUBLISH_BUTTON_LABEL_SHADOW_YOFFSET)];
	self.publishButtonTitle = [[NSAttributedString alloc] initWithString:PUBLISH_BUTTON_LABEL attributes:@{NSForegroundColorAttributeName: labelColor, NSFontAttributeName : labelFont, NSShadowAttributeName : shadow}];
	[self.publishButton setAttributedTitle:self.publishButtonTitle forState:UIControlStateNormal];

	[self.publishButton addTarget:self action:@selector(publishArticleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.publishButton];
}


// if show, return scrollView to its previous position
// else remove scrollview
-(void)showScrollView: (BOOL) show {
    if(show)  {
        [UIView animateWithDuration:PUBLISH_ANIMATION_DURATION animations:^{
             self.articleCurrentlyViewing= YES;
             self.scrollView.frame = self.view.bounds;
			 self.publishButton.frame = self.publishButtonFrame;
        } completion:^(BOOL finished) {
			[self.publishButton startGlowing];
		}];
    }else {
		[self.publishButton stopGlowing];
        [UIView animateWithDuration:PUBLISH_ANIMATION_DURATION animations:^{
            self.scrollView.frame = self.scrollViewRestingFrame;
			self.publishButton.frame = self.publishButtonRestingFrame;
        }completion:^(BOOL finished) {
            if(finished) {
                self.articleCurrentlyViewing = NO;
                [self clearArticle];
            }
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //TODO: Dispose of any resources that can be recreated.
}

#pragma mark - Rendering article

//called when we want to present an article. article should be set with our content
-(void)showArticle:(NSNotification *) notification
{
	Article* article = [[notification userInfo] objectForKey:@"article"];
	NSMutableArray* pinchObjects = [[notification userInfo] objectForKey:@"pinchObjects"];
	if(article) {
		[self showArticleFromParse: article];
	}else{
		[self showArticlePreview: pinchObjects];
	}
}

-(void) showArticleFromParse:(Article *) article {
	[self setUpScrollView];
	[self showScrollView:YES];
	[self startActivityIndicator];

	dispatch_queue_t articleDownload_queue = dispatch_queue_create("articleDisplay", NULL);
	dispatch_async(articleDownload_queue, ^{
		NSArray * pages = [article getAllPages];
		//if we have nothing in our article then return to the list view- we shouldn't need this because all downloaded articles should have legit pages
		if(!pages.count) {
			NSLog(@"No pages in article");
			[self showScrollView:NO];
			return;
		}

		//we sort the pages by their page numbers to make sure everything is in the right order
		//O(nlogn) so should be fine in the long-run ;D
		pages = [pages sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			Page * page1 = obj1;
			Page * page2 = obj2;
			if(page1.pagePosition < page2.pagePosition)return -1;
			if(page2.pagePosition > page1.pagePosition) return 1;
			return 0;
		}];
		dispatch_async(dispatch_get_main_queue(), ^{
			NSMutableArray * pinchObjectsArray = [[NSMutableArray alloc]init];
			//get pinch views for our array
			for (Page * page in pages) {
				//here the radius and the center dont matter because this is just a way to wrap our data for the analyser
				PinchView * pinchView = [page getPinchObjectWithRadius:0 andCenter:CGPointMake(0, 0)];
				if (!pinchView) {
					NSLog(@"Pinch view from parse should not be Nil.");
					return;
				}
				[pinchObjectsArray addObject:pinchView];
			}
			AVETypeAnalyzer * analyser = [[AVETypeAnalyzer alloc]init];
			self.pageAVEs = [analyser processPinchedObjectsFromArray:pinchObjectsArray withFrame:self.view.frame];

			if(!self.pageAVEs.count)return;//for now
												 //stop animation indicator
			[self stopActivityIndicator];
			[self renderPinchPages];
			self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, [self.pageAVEs count]*self.view.frame.size.height); //adjust contentsize to fit
			self.lastPoint = CGPointZero;
			self.animatingView = nil;
		});
	});
}

-(void) showArticlePreview:  (NSMutableArray*) pinchObjects {
	AVETypeAnalyzer * analyser = [[AVETypeAnalyzer alloc]init];
	self.pageAVEs = [analyser processPinchedObjectsFromArray:pinchObjects withFrame:self.view.frame];
	self.view.backgroundColor = [UIColor clearColor];
	[self setUpScrollView];
	[self renderPinchPages];
	[self addPublishButton];
	[self showScrollView:YES];
	self.lastPoint = CGPointZero;
	self.animatingView = nil;
}

-(void) clearArticle {
	//We clear these so that the media is released

	for(UIView *view in self.scrollView.subviews) {
		[view removeFromSuperview];
	}
	self.scrollView = NULL;
	self.animatingView = NULL;
	self.poppedOffPages = NULL;
	self.pageAVEs = Nil;//sanitize array so memory is cleared
}

//takes AVE pages and displays them on our scrollview
-(void)renderPinchPages {
    CGRect viewFrame = self.view.bounds;
    
    for(UIView* view in self.pageAVEs){
        if([view isKindOfClass:[TextAVE class]]){
            view.frame = viewFrame;
            [self.scrollView addSubview: view];
            viewFrame = CGRectOffset(viewFrame, 0, self.view.frame.size.height);
            continue;
        }
        [self.scrollView insertSubview:view atIndex:0];
        view.frame = viewFrame;
        viewFrame = CGRectOffset(viewFrame, 0, self.view.frame.size.height);
    }

    [self setUpGestureRecognizers];
}

#pragma mark - Gesture recognizers

//Sets up the gesture recognizer for dragging from the edges.
-(void) setUpGestureRecognizers {
	self.panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(scrollView:)];
	self.panGesture.delegate = self;
	[self.scrollView addGestureRecognizer:self.panGesture];
}

-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}

-(void) scrollView:(UIPanGestureRecognizer*) sender {
	switch (sender.state) {
		case UIGestureRecognizerStateBegan: {
			if ([sender numberOfTouches] != 1) return;
			CGPoint touchLocation = [sender locationOfTouch:0 inView:self.view];
			if (touchLocation.y < (self.view.frame.size.height - self.pageScrollTopBottomArea)
				&& touchLocation.y > self.pageScrollTopBottomArea) {
				self.scrollView.scrollEnabled = NO;
			}
			break;
		}
		case UIGestureRecognizerStateChanged: {
			break;
		}
		case UIGestureRecognizerStateEnded: {
			self.scrollView.scrollEnabled = YES;
			break;
		}
		default:
			break;
	}
}

//called from left edge pan in master navigation vc
- (void)exitDisplay:(UIScreenEdgePanGestureRecognizer *)sender {

	switch (sender.state) {
		case UIGestureRecognizerStateBegan: {
			//we want only one finger doing anything when exiting
			if([sender numberOfTouches] != 1) {
				return;
			}
			CGPoint touchLocation = [sender locationOfTouch:0 inView:self.view];
			self.previousGesturePoint  = touchLocation;
			[self.publishButton stopGlowing];
			break;
		}
		case UIGestureRecognizerStateChanged: {
			CGPoint touchLocation = [sender locationOfTouch:0 inView:self.view];
			CGPoint currentPoint = touchLocation;
			int diff = currentPoint.x - self.previousGesturePoint.x;
			self.previousGesturePoint = currentPoint;
			self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x +diff, self.scrollView.frame.origin.y,  self.scrollView.frame.size.width,  self.scrollView.frame.size.height);
			self.publishButton.frame = CGRectMake(self.publishButton.frame.origin.x +diff, self.publishButton.frame.origin.y,  self.publishButton.frame.size.width,  self.publishButton.frame.size.height);
			break;
		}
		case UIGestureRecognizerStateEnded: {
			if(self.scrollView.frame.origin.x > EXIT_EPSILON) {
				//exit article
				[self showScrollView:NO];
				[self cleanUp];
			}else{
				//return view to original position
				[self showScrollView:YES];
			}
			break;
		}
		default:
			break;
	}

}




@end
