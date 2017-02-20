#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVUtil : NSObject

+ (UIImage *)convertImage: (UIImage *)image;
+ (UIImage *)cropImage: (UIImage *)image;
+ (UIImage *)resizeImage: (UIImage *)image;
//+ (UIImage *)resize256x256: (UIImage *)image;
+ (bool) saveImage: (UIImage *)image path:(NSString *)path;

+ (UIImage *)faceDetectForImage: (UIImage *)image;
+ (NSArray *)facePointDetectForImage: (UIImage *)image;

+ (UIImage *)cardDetectForImage: (UIImage *)image;
+ (NSArray *)cardPointDetectForImage: (UIImage *)image;

//+ (UIImage *)circleDetectForImage: (UIImage *)image;

@end
