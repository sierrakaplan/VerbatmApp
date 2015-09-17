//
//  PovInfo.m
//  Verbatm
//
//
//

#import "PovInfo.h"

@implementation PovInfo

@dynamic coverPicUrl;

-(instancetype) initWithGTLVerbatmAppPovInfo: (GTLVerbatmAppPOVInfo*) gtlPovInfo andCoverPhoto: (UIImage*) coverPhoto {
	self = [super init];
	if (self) {
		self.coverPicUrl = gtlPovInfo.coverPicUrl;
		self.creatorUserId = gtlPovInfo.creatorUserId;
		self.datePublished = gtlPovInfo.datePublished;
		self.identifier = gtlPovInfo.identifier;
		self.numUpVotes = gtlPovInfo.numUpVotes;
		self.title = gtlPovInfo.title;
		self.coverPhoto = coverPhoto;
	}
	return self;
}

@end
