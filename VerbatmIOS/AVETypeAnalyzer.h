//
//  v_Analyzer.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "ArticleViewingExperience.h"

#import <Foundation/Foundation.h>
#import <Parse/PFObject.h>
#import <PromiseKit/PromiseKit.h>

@class Page;



typedef enum AveTypes{
    AveTypePhoto = 0,
    AveTypeVideo = 1,
    AveTypePhotoVideo = 2,
}AveTypes;


@interface AVETypeAnalyzer : NSObject

-(NSMutableArray*) getAVESFromPinchViews:(NSArray*) pinchViews withFrame:(CGRect)frame inPreviewMode: (BOOL) inPreviewMode ;

// returns a promise that either resolves to an ave or error
-(void) getAVEFromPage: (PFObject *)page withFrame: (CGRect) frame andCompletionBlock:(void(^)(ArticleViewingExperience *))block;

@end
