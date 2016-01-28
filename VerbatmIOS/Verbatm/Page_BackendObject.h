//
//  Page_BackendObject.h
//  Verbatm
//
//  Created by Iain Usiri on 1/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/PFObject.h>
#import "PinchView.h"
@interface Page_BackendObject : NSObject
//make sure the post is arleady saved in the database before this function is called
-(void)savePageWithIndex:(NSInteger) pageIndex andPinchView:(PinchView *) pinchView andPost:(PFObject *) post;

@end
