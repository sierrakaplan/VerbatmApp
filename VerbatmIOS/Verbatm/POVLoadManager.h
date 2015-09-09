//
//  POVLoadManager.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/7/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GTLVerbatmAppPOVInfo;

@interface POVLoadManager : NSObject

typedef NS_ENUM(NSInteger, POVType) {
	POVTypeTrending,
	POVTypeRecent
};

-(id) initWithType: (POVType) type;

-(void) loadPOVs: (NSInteger) numToLoad;

- (GTLVerbatmAppPOVInfo*) getPOVInfoAtIndex: (NSInteger) index;

-(NSInteger) getNumberOfPOVsLoaded;

@end
