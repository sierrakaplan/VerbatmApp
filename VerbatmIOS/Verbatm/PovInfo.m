//
//  PovInfo.m
//  Verbatm
//
//
//

#import "PovInfo.h"

@implementation PovInfo

-(instancetype) initWithGTLVerbatmAppPovInfo: (GTLVerbatmAppPOVInfo*) gtlPovInfo
								 andUserName:(NSString*)userName
			   andUserIDsWhoHaveLikedThisPOV:(NSArray*) userIDs{
	self = [super init];
	if (self) {
		self.userName = userName;
		self.userIDsWhoHaveLikedThisPOV = userIDs;

		self.creatorUserId = gtlPovInfo.creatorUserId;
		self.datePublished = gtlPovInfo.datePublished;
		self.identifier = gtlPovInfo.identifier;
		self.numUpVotes = gtlPovInfo.numUpVotes;
		self.title = gtlPovInfo.title;
	}
	return self;
}

@end
