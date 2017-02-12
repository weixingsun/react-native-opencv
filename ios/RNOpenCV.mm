#import "RNOpenCV.h"
#import "OpenCVUtil.h"
#import "CIDetectorUtil.h"
#import <opencv2/opencv.hpp>
#import <UIKit/UIKit.h>
@implementation RNOpenCV
//maybe CIDetector can also do the same thing
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(faceData:(NSString *)path
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    UIImage *img = [[UIImage alloc] initWithData:data];
    NSArray *arr = [OpenCVUtil facePointDetectForImage:img];
    NSDictionary *ret = @{};
    BOOL success = YES;
    NSString *errmsg = @"";
    if(arr.count<1) {
        success=NO;
        errmsg = [NSString stringWithFormat:@"no face detected"];
    }else if(arr.count>1){
        success=NO;
        errmsg = [NSString stringWithFormat:@"multiple faces detected: '%i'", arr.count];
    }else{
        for (NSNumber* rectValue in arr) {
            CGRect rect = [rectValue CGRectValue];
            ret= @{
             @"x": @(rect.origin.x),
             @"y": @(rect.origin.y),
             @"w": @(rect.size.width),
             @"h": @(rect.size.height)
            };
        }
    }
  if (!success) {
    return reject(@"error", errmsg, nil);
  }
  return resolve(ret);
}

RCT_EXPORT_METHOD(faceImage:(NSString *)pathIn
                     output:(NSString *)pathOut
                   resolver:(RCTPromiseResolveBlock)resolve
                   rejecter:(RCTPromiseRejectBlock)reject)
{
    NSData *data = [NSData dataWithContentsOfFile:pathIn];
    UIImage *imgIn = [[UIImage alloc] initWithData:data];
    UIImage *imgOut = [OpenCVUtil faceDetectForImage:imgIn];
    //NSData *imgData = [UIImageJPEGRepresentation(imgOut)];
    if([UIImageJPEGRepresentation(imgOut, 1.0) writeToFile:pathOut atomically:YES]) {
        return resolve(pathOut);
    }else{
        NSString *errmsg = [NSString stringWithFormat:@"failed to write file"];
        return reject(@"error", errmsg, nil);
    }
}
RCT_EXPORT_METHOD(cardData:(NSString *)path
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    UIImage *img = [[UIImage alloc] initWithData:data];
    NSArray *arr = [OpenCVUtil cardPointDetectForImage:img];
    NSDictionary *ret = @{};
    BOOL success = YES;
    NSString *errmsg = @"";
    if(arr.count<1) {
        success=NO;
        errmsg = [NSString stringWithFormat:@"no card detected"];
    }else if(arr.count>1){
        success=NO;
        errmsg = [NSString stringWithFormat:@"multiple cards/squares detected: '%i'", arr.count];
    }else{
        for (NSNumber* rectValue in arr) {
            CGRect rect = [rectValue CGRectValue];
            ret= @{
             @"x": @(rect.origin.x),
             @"y": @(rect.origin.y),
             @"w": @(rect.size.width),
             @"h": @(rect.size.height)
            };
        }
    }
  if (!success) {
    return reject(@"error", errmsg, nil);
  }
  return resolve(ret);
}
RCT_EXPORT_METHOD(cardImage:(NSString *)pathIn
                  output:(NSString *)pathOut
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSData *data = [NSData dataWithContentsOfFile:pathIn];
    UIImage *imgIn = [[UIImage alloc] initWithData:data];
    //UIImage *imgOut = [CIDetectorUtil cardDetectForImage:imgIn];
    UIImage *imgOut = [OpenCVUtil cardDetectForImage:imgIn];
    if([UIImageJPEGRepresentation(imgOut, 1.0) writeToFile:pathOut atomically:YES]) {
        return resolve(pathOut);
    }else{
        NSString *errmsg = [NSString stringWithFormat:@"failed to write file"];
        return reject(@"error", errmsg, nil);
    }
}
- (CGRect)convertRectFromRect:(CGRect)fromRect toSize:(CGSize)size{
    
    return CGRectMake(size.width*fromRect.origin.x, size.height*fromRect.origin.y,size.width*fromRect.size.width, size.height*fromRect.size.height);
}

@end


