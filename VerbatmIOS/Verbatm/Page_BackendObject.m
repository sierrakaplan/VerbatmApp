//
//  Page_BackendObject.m
//  Verbatm
//
//  Created by Iain Usiri on 1/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//


#import "AVETypeAnalyzer.h"
#import <Parse/PFQuery.h>

#import "Page_BackendObject.h"
#import "ParseBackendKeys.h"
#import "Photo_BackendObject.h"
#import "Video_BackendObject.h"
@interface Page_BackendObject ()
@property (strong) NSMutableArray * photoAndVideoSavers;
@end
@implementation Page_BackendObject


-(instancetype)init{
    self = [super init];
    if(self){
        self.photoAndVideoSavers = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)savePageWithIndex:(NSInteger) pageIndex andPinchView:(PinchView *) pinchView andPost:(PFObject *) post{
    
    //create and save page object
    PFObject * newPageObject = [PFObject objectWithClassName:PAGE_PFCLASS_KEY];
    [newPageObject setObject:[NSNumber numberWithInteger:pageIndex] forKey:PAGE_INDEX_KEY];
    [newPageObject setObject:post forKey:PAGE_POST_KEY];
    
    if (pinchView.containsImage && pinchView.containsVideo) {
        [newPageObject setObject:[NSNumber numberWithInt:AveTypePhotoVideo] forKey:PAGE_AVE_TYPE];
        
    } else if (pinchView.containsImage) {
        [newPageObject setObject:[NSNumber numberWithInt:AveTypePhoto] forKey:PAGE_AVE_TYPE];
    } else {
        [newPageObject setObject:[NSNumber numberWithInt:AveTypeVideo] forKey:PAGE_AVE_TYPE];
    }
    
    
    
    [newPageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){//now we save the media for the specific
            [self storeImagesFromPinchView:pinchView withPageReference:newPageObject];
            [self storeVideosFromPinchView:pinchView withPageReference:newPageObject];
        }
    }];
    
}


// when(stored every image)
// Each storeimage promise should resolve to the id of the GTL Image just stored
// So this promise should resolve to an array of gtl image id's
-(void) storeImagesFromPinchView: (PinchView*) pinchView withPageReference:(PFObject *) page{
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
            
            Photo_BackendObject * photoObj = [[Photo_BackendObject alloc] init];
            [self.photoAndVideoSavers addObject:photoObj];
            [photoObj saveImage:uiImage withText:text andTextYPosition:textYPosition atPhotoIndex:i andPageObject:page];
        }
    }
}



-(void) storeVideosFromPinchView: (PinchView*) pinchView withPageReference:(PFObject *) page{
    if (pinchView.containsVideo)
    {
        //Publishing videos sequentially
        NSArray* pinchViewVideosWithText = [pinchView getVideosWithText];
        for (int i = 0; i < pinchViewVideosWithText.count; i++){
                NSArray* videoWithText = pinchViewVideosWithText[i];
                AVURLAsset* videoAsset = videoWithText[0];
               //NSString* text = videoWithText[1];
               //NSNumber* textYPosition = videoWithText[2];
                Video_BackendObject  * videoObj = [[Video_BackendObject alloc] init];
            [self.photoAndVideoSavers addObject:videoObj];
               [videoObj saveVideo:videoAsset.URL atVideoIndex:i andPageObject:page];
        }
    }
}




+(void)getPagesFromPost:(PFObject *) post andCompletionBlock:(void(^)(NSArray *))block{
    
    PFQuery * userChannelQuery = [PFQuery queryWithClassName:PAGE_PFCLASS_KEY];
    [userChannelQuery whereKey:PAGE_POST_KEY equalTo:post];
    [userChannelQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                         NSError * _Nullable error) {
        if(objects && !error){
            [objects sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                PFObject * pageA = obj1;
                PFObject * pageB = obj2;
                
                NSNumber * pageAnum = [pageA valueForKey:PAGE_INDEX_KEY];
                NSNumber * pageBnum = [pageB valueForKey:PAGE_INDEX_KEY];
                
                if([pageAnum integerValue] > [pageBnum integerValue]){
                    return NSOrderedDescending;
                }else if ([pageAnum integerValue] < [pageBnum integerValue]){
                    return NSOrderedAscending;
                }
                return NSOrderedSame;
            }];
            block(objects);
        }
        
    }];
    
}



@end
