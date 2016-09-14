//
//  PhotoPveEditView.h
//  Verbatm
//
//  Created by Iain Usiri on 9/12/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "PhotoPVE.h"

@interface PhotoPveEditView : PhotoPVE

// initializer for PREVIEW MODE
// PinchView can be either ImagePinchView or CollectionPinchView
-(instancetype) initWithFrame:(CGRect)frame andPinchView:(PinchView *)pinchView isPhotoVideoSubview:(BOOL)halfScreen;
@end
