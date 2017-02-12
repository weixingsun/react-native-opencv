#import "CIDetectorUtil.h"
@implementation CIDetectorUtil

+ (NSArray*)facePointDetectForImage:(UIImage*)image{
    return nil;
}
+ (UIImage*)faceDetectForImage:(UIImage*)image {
    return nil;
}
+ (NSArray*)cardPointDetectForImage:(UIImage*)image{
    CIImage *img = image.CIImage;//[CIDetectorUtil filterImage:image.CIImage];
    return [[CIDetectorUtil getDetector] featuresInImage:img];
}
+ (UIImage*)cardDetectForImage:(UIImage*)image{
    CIRectangleFeature *feature = [CIDetectorUtil maxRect:[CIDetectorUtil cardPointDetectForImage:image]];
    if(feature==nil) {
        NSLog(@"cardDetectForImage() No squares detect");
        return image;
    }
    CIImage *img = [CIDetectorUtil drawForPoints:img feature:feature];
    return [[UIImage alloc] initWithCIImage:img];
}
+ (CIDetector *)getDetector{
    static CIDetector *detector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        detector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyLow,CIDetectorAspectRatio:@2.0}];
    });
    return detector;
}
+  (CIImage *) filterImage:(CIImage *)image {
    CIImage *img= [CIFilter filterWithName:@"CIColorControls" withInputParameters:@{@"inputContrast":@(1.1),kCIInputImageKey:image}].outputImage;
    return img;
}
+ (CIRectangleFeature *)maxRect:(NSArray *)rectangles{
    if (![rectangles count]) return nil;
    float halfPerimiterValue = 0;
    CIRectangleFeature *biggestRectangle = [rectangles firstObject];
    for (CIRectangleFeature *rect in rectangles){
        CGPoint p1 = rect.topLeft;
        CGPoint p2 = rect.topRight;
        CGFloat width = hypotf(p1.x - p2.x, p1.y - p2.y);
        CGPoint p3 = rect.topLeft;
        CGPoint p4 = rect.bottomLeft;
        CGFloat height = hypotf(p3.x - p4.x, p3.y - p4.y);
        CGFloat currentHalfPerimiterValue = height + width;
        
        if (halfPerimiterValue < currentHalfPerimiterValue){
            halfPerimiterValue = currentHalfPerimiterValue;
            biggestRectangle = rect;
        }
    }
    return biggestRectangle;
}
+ (CIImage *)drawForPoints:(CIImage *)image feature:(CIRectangleFeature *)feature
{
    CIImage *overlay = [CIImage imageWithColor:[CIColor colorWithRed:1 green:0 blue:0 alpha:0.6]];
    overlay = [overlay imageByCroppingToRect:image.extent];
    overlay = [overlay imageByApplyingFilter:@"CIPerspectiveTransformWithExtent" withInputParameters:@{@"inputExtent":[CIVector vectorWithCGRect:image.extent],@"inputTopLeft":[CIVector vectorWithCGPoint:feature.topLeft],@"inputTopRight":[CIVector vectorWithCGPoint:feature.topRight],@"inputBottomLeft":[CIVector vectorWithCGPoint:feature.bottomLeft],@"inputBottomRight":[CIVector vectorWithCGPoint:feature.bottomRight]}];
    
    return [overlay imageByCompositingOverImage:image];
}
@end
