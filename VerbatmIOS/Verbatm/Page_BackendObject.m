//
//  Page_BackendObject.m
//  Verbatm
//
//  Created by Iain Usiri on 1/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Page_BackendObject.h"
#import "ParseBackendKeys.h"
#import "Photo_BackendObject.h"
#import "Video_BackendObject.h"
@implementation Page_BackendObject


+(void)savePageWithIndex:(NSInteger) pageIndex andPinchView:(PinchView *) pinchView andPost:(PFObject *) post{
    
    //create and save page object
    PFObject * newPhotoObject = [PFObject objectWithClassName:PAGE_PFCLASS_KEY];
    [newPhotoObject setObject:[NSNumber numberWithInteger:pageIndex] forKey:PAGE_INDEX_KEY];
    [newPhotoObject setObject:post forKey:PAGE_POST_KEY];
    [newPhotoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){//now we save the media for the specific
            [Page_BackendObject storeImagesFromPinchView:pinchView withPageReference:newPhotoObject];
            [Page_BackendObject storeVideosFromPinchView:pinchView withPageReference:newPhotoObject];
        }
    }];
    
}


// when(stored every image)
// Each storeimage promise should resolve to the id of the GTL Image just stored
// So this promise should resolve to an array of gtl image id's
+(void) storeImagesFromPinchView: (PinchView*) pinchView withPageReference:(PFObject *) page{
    if (pinchView.containsImage)
    {
        //Publishing images sequentially
        NSArray* pinchViewPhotosWithText = [pinchView getPhotosWithText];
        for (int i = 0; i < pinchViewPhotosWithText.count; i++)
        {
            NSArray* photoWithText = pinchViewPhotosWithText[i];
            UIImage* uiImage = photoWithText[0];
            NSString* text = photoWithText[1];
            NSNumber* textYPosition = photoWithText[2];
            [Photo_BackendObject saveImage:uiImage withText:text andTextYPosition:textYPosition atPhotoIndex:i andPageObject:page];
        }
    }
}



+(void) storeVideosFromPinchView: (PinchView*) pinchView withPageReference:(PFObject *) page{
    if (pinchView.containsImage)
    {
        //Publishing videos sequentially
        NSArray* pinchViewVideosWithText = [pinchView getVideosWithText];
        for (int i = 0; i < pinchViewVideosWithText.count; i++){
                NSArray* videoWithText = pinchViewVideosWithText[i];
                AVURLAsset* videoAsset = videoWithText[0];
               //NSString* text = videoWithText[1];
               //NSNumber* textYPosition = videoWithText[2];
               [Video_BackendObject saveVideo:videoAsset.URL atVideoIndex:i andPageObject:page];
        }
    }
}



@end
