#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVUtil : NSObject

+ (UIImage *)convertImage: (UIImage *)image;

+ (UIImage *)faceDetectForImage: (UIImage *)image;
+ (NSArray *)facePointDetectForImage: (UIImage *)image;

+ (UIImage *)cardDetectForImage: (UIImage *)image;
+ (NSArray *)cardPointDetectForImage: (UIImage *)image;

//+ (UIImage *)circleDetectForImage: (UIImage *)image;

@end
