//
//  v_Analyzer.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <PromiseKit/PromiseKit.h>

@class Page;

@interface AVETypeAnalyzer : NSObject

-(NSMutableArray*) getAVESFromPinchViews:(NSArray*) pinchViews withFrame:(CGRect)frame;

// not in use!
-(NSMutableArray*) getAVESFromPages: (NSArray*) pages withFrame: (CGRect) frame;

// returns a promise that either resolves to an ave or error
-(AnyPromise*) getAVEFromPage: (Page*) page withFrame: (CGRect) frame;

@end
