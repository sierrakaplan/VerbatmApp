//
//  BlobstoreUploader.h
//  Verbatm
//
//  Takes a piece of media (image or video data) and gets a blobstore upload uri
// for it from the server. It then creates a MediaUploader instance
// for the image or video with this uri so that the MediaUploader can
// upload it to the blobstore.
//

#import <Foundation/Foundation.h>

@interface BlobstoreUploader : NSObject

-(void) uploadImage: (UIImage*) image;

-(void) uploadVideo: (NSData*) videoData;

@end
