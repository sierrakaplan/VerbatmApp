//
//  v_Analyzer.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface AVETypeAnalyzer : NSObject

typedef NS_ENUM(NSInteger, AVEType) {
	AVETypeVideo,
	AVETypePhoto,
	AVETypePhotoVideo
};

-(NSMutableArray*)processPinchedObjectsFromArray:(NSMutableArray*)arr withFrame:(CGRect)frame;
@end
