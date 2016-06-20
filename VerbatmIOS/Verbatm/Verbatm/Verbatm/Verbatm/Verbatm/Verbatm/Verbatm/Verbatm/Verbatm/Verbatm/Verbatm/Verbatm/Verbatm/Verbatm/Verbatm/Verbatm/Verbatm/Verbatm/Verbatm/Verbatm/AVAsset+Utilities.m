//
//  AVAsset+Utilities.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 10/6/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "AVAsset+Utilities.h"

@implementation AVAsset (Utilities)

//takes an asset and gets the first frame of the video
-(UIImage *) getThumbnailFromAsset {
	@autoreleasepool {
		AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset: self];
		imageGenerator.appliesPreferredTrackTransform = YES;
		CMTime time = [self duration];
		time.value = 0;
		CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
		UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
		CGImageRelease(imageRef);
		return thumbnail;
	}
}

@end
