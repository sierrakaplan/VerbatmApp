//
//  VideoPveEditingView.h
//  Verbatm
//
//  Created by Iain Usiri on 9/12/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "VideoPVE.h"
#import "EditMediaContentView.h"
@interface VideoPveEditingView : VideoPVE
// Initializer for preview mode
-(instancetype) initWithFrame:(CGRect)frame andPinchView: (PinchView*) pinchView isPhotoVideoSubview:(BOOL)halfScreen;

@end
