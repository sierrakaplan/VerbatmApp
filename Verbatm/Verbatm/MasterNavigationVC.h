//
//  verbatmMasterNavigationViewController.h
//  Verbatm
//
//  Created by Iain Usiri on 5/20/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VerbatmCameraView;
@class MediaSessionManager;

@interface MasterNavigationVC : UIViewController
    @property(strong, nonatomic) NSMutableArray * pinchObjects;
	@property (strong, nonatomic) VerbatmCameraView* verbatmCameraView;
	@property (strong, nonatomic) MediaSessionManager* sessionManager;
	+ (BOOL) inTestingMode;
@end
