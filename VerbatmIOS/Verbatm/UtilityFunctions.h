//
//  UseFulFunctions.h
//  Verbatm
//
//  Created by Iain Usiri on 9/27/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface UtilityFunctions : NSObject

+(NSData *) convertALAssetRepresentationToData: (ALAssetRepresentation *) assetRep;

@end
