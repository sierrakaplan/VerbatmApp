//
//  verbatmArticleUploader.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 3/27/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Article.h"

@interface verbatmArticleUploader : NSObject

/*This method constructs an article from the pinch object and saves it*/
/*The method returns a boolean if the saving was done successfully*/
/*Method blocks, should not be called on main thread*/
-(BOOL)saveArticleWithPinchObjects:(NSArray *)pinchObjects title:(NSString *)title withSandwichFirst:(NSString *)firstPart andSecond:(NSString*)secondPart;
@end
