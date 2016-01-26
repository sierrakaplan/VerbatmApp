
//
//  Post.m
//  Verbatm
//
//  Created by Iain Usiri on 1/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.


#import "Post_BackendObject.h"
#import "PinchView.h"
#import "CollectionPinchView.h"
#import "VideoPinchView.h"

@implementation Post_BackendObject


+(void) createPostFromPinchViews: (NSArray*) pinchViews toChannel: (Channel *) channel{
    
    for (PinchView* pinchView in pinchViews) {
        NSArray* photos = [pinchView getPhotosWithText];
        NSArray* videos = [pinchView getVideosWithText];
        
    }
    
    
    
    
}


+(NSMutableArray *) getPostsInChannel:(Channel *) channel{
    
    
    
    return @[];
}



@end
