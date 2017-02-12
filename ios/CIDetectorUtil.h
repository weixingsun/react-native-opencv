#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CIDetectorUtil : NSObject

+ (UIImage *)faceDetectForImage: (UIImage *)image;
+ (NSArray *)facePointDetectForImage: (UIImage *)image;

+ (UIImage *)cardDetectForImage: (UIImage *)image;
+ (NSArray *)cardPointDetectForImage: (UIImage *)image;
+ (CIDetector *)getDetector;
+ (CIRectangleFeature *)maxRect:(NSArray *)rectangles;
+ (CIImage *) filterImage:(CIImage *)image;
+ (CIImage *)drawForPoints:(CIImage *)image feature:(CIRectangleFeature *)feature;
@end
