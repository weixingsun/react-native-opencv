#import "OpenCVUtil.h"

#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>
//maybe CIDetector can also do the same thing
using namespace std;
@implementation OpenCVUtil

static int thresh = 50, N = 10;
static float tolerance = 20*M_PI/180;//0.4;
static int accuracy = 0;
NSString *TRAINING_DATA = @"haarcascade_frontalface_alt";
//NSString *TRAINING_DATA = @"haarcascade_frontalface_alt2";  //err
//NSString *TRAINING_DATA = @"haarcascade_frontalface_alt_tree";
//NSString *TRAINING_DATA = @"haarcascade_frontalface_default"; //err

+ (UIImage *)convertImage: (UIImage *)image {
    // 初始化一个图片的二维矩阵cvImage
    cv::Mat cvImage;
    // 将图片UIImage对象转为Mat对象
    UIImageToMat(image, cvImage);
    if (!cvImage.empty()) {
        cv::Mat gray;
        // 进一步将图片转为灰度显示
        cv::cvtColor(cvImage, gray, CV_RGB2GRAY);
        // 利用搞死滤镜去除边缘
        cv::GaussianBlur(gray, gray, cv::Size(5, 5), 1.2, 1.2);
        // 计算画布
        cv::Mat edges;
        cv::Canny(gray, edges, 0, 50);
        // 使用白色填充
        cvImage.setTo(cv::Scalar::all(225));
        // 修改边缘颜色
        cvImage.setTo(cv::Scalar(0,128,255,255),edges);
        // 将Mat转换为UIImage
        return MatToUIImage(cvImage);
    }
    return nil;
}

+ (NSArray*)facePointDetectForImage:(UIImage*)image{
    static cv::CascadeClassifier faceDetector;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString* cascadePath = [[NSBundle mainBundle]
                                 pathForResource:TRAINING_DATA
                                 ofType:@"xml"];
        faceDetector.load([cascadePath UTF8String]);
    });
    cv::Mat faceImage;
    UIImageToMat(image, faceImage);
    // 转为灰度
    cv::Mat gray;
    cvtColor(faceImage, gray, CV_BGR2GRAY);
    // 检测人脸并储存
    vector<cv::Rect>faces;
    faceDetector.detectMultiScale(gray, faces,1.1,2,CV_HAAR_FIND_BIGGEST_OBJECT,cv::Size(30,30));
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned int i= 0;i < faces.size();i++){
        const cv::Rect& face = faces[i];
        float height = (float)faceImage.rows;
        float width = (float)faceImage.cols;
        CGRect rect = CGRectMake(face.x/width, face.y/height, face.width/width, face.height/height);
        [array addObject:[NSNumber valueWithCGRect:rect]];
    }
    return [array copy];
}
+ (UIImage*)faceDetectForImage:(UIImage*)image {
    static cv::CascadeClassifier faceDetector;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString* cascadePath = [[NSBundle mainBundle]
                        pathForResource:TRAINING_DATA
                                 ofType:@"xml"];
        faceDetector.load([cascadePath UTF8String]);
    });
    cv::Mat faceImage;
    UIImageToMat(image, faceImage);
    // 转为灰度
    cv::Mat gray;
    cvtColor(faceImage, gray, CV_BGR2GRAY);
    // 检测人脸并储存
    vector<cv::Rect>faces;
    faceDetector.detectMultiScale(gray, faces,1.1,2,0,cv::Size(30,30));
    // 在每个人脸上画一个红色四方形
    for(unsigned int i= 0;i < faces.size();i++) {
        const cv::Rect& face = faces[i];
        cv::Point tl(face.x,face.y);
        cv::Point br = tl + cv::Point(face.width,face.height);
        // 四方形的画法
        cv::Scalar magenta = cv::Scalar(255, 0, 0, 255);
        cv::rectangle(faceImage, tl, br, magenta, 2, 8, 0);
    }
    return MatToUIImage(faceImage);
}

//+ (UIImage*)circleDetectForImage:(UIImage*)image{
//    cv::Mat circleImage,src_gray;
//    UIImageToMat(image, circleImage);
//    /// Convert it to gray
//    cvtColor( circleImage, src_gray, CV_BGR2GRAY );
//    
//    /// Reduce the noise so we avoid false circle detection
//    GaussianBlur( src_gray, src_gray, cv::Size(9, 9), 2, 2 );
//    
//    vector<cv::Vec3f> circles;
//    
//    /// Apply the Hough Transform to find the circles
//    HoughCircles( src_gray, circles, CV_HOUGH_GRADIENT, 1, src_gray.rows/8, 200, 100, 0, 0 );
//    
//    /// Draw the circles detected
//    for( size_t i = 0; i < circles.size(); i++ )
//    {
//        cv::Point center(cvRound(circles[i][0]), cvRound(circles[i][1]));
//        int radius = cvRound(circles[i][2]);
//        // circle center
//        circle( circleImage, center, 3, cv::Scalar(0,255,0,255), -1, 8, 0 );
//        // circle outline
//        circle( circleImage, center, radius, cv::Scalar(0,0,255,255), 3, 8, 0 );
//    }
//    
//    /// Show your results
//    
//    return MatToUIImage(circleImage);
//    
//}
+ (NSArray*)cardEdgePointDetectForImage:(UIImage*)image{
    return nil;
}
+ (UIImage*)cardDetectForImage:(UIImage*)image{
    cv::Mat src;
    UIImageToMat(image, src);
    vector<vector<cv::Point> > squares;
    cv::Mat src_gray;
    cv::cvtColor(src, src_gray, cv::COLOR_BGR2GRAY);
    // Blur helps to decrease the amount of detected edges
    cv::Mat src_filtered;
    //cv::blur(src_gray, src_filtered, cv::Size(3, 3));
    cv::GaussianBlur(src_gray, src_filtered, cv::Size(3, 3),0,0);
    findSquares(src_filtered, squares);

    vector<cv::Point> largest_square;
    findMaxSquare(squares, largest_square);
    /*for (size_t i = 0; i < squares.size(); i++) {
        const cv::Point* p = &squares[i][0];
        int n = (int)squares[i].size();
        cv::polylines(src, &p, &n, 1, true, cv::Scalar(0,0,255,0), 2, CV_AA);
    }*/
    // Draw circles at the corners
    for (size_t i = 0; i < largest_square.size(); i++ ){
        cv::circle(src, largest_square[i], 3, cv::Scalar(0,0,255,0), cv::FILLED);
        int n = (int)largest_square.size();
        //NSLog(@"cardDetectForImage.largest_square: %i",n);
        //cv::polylines(src, &largest_square[i], &n, 1, true, cv::Scalar(0,0,255,0), 2, CV_AA);
    }
    //cv::imwrite("out_corners.jpg", src);
    //cv::imshow("Corners", src);
    //cv::waitKey(0);
    return MatToUIImage(src);
}

/* angle: finds a cosine of angle between vectors, from pt0->pt1 and from pt0->pt2
 */
double angle(cv::Point pt1, cv::Point pt2, cv::Point pt0){
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1*dx2 + dy1*dy2)/sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
}
void findSquares(cv::Mat& image, vector<vector<cv::Point> >& squares ) {
    squares.clear();
    cv::Mat pyr, timg, gray0(image.size(), CV_8U), gray;
    // down-scale and upscale the image to filter out the noise
    cv::pyrDown(image, pyr, cv::Size(image.cols/2, image.rows/2));
    cv::pyrUp(pyr, timg, image.size());
    vector<vector<cv::Point> > contours;
    // find squares in every color plane of the image
    int planes = 1;
    int canny = 0;
    if (accuracy) {
        planes = 4;
        canny = 1;
    }
    for( int c = 0; c < planes; c++ ) {
        int ch[] = {c, 0};
        cv::mixChannels(&timg, 1, &gray0, 1, ch, 1);
        // try several threshold levels
        for( int l = 0; l < N; l++ ) {
            // hack: use Canny instead of zero threshold level.
            // Canny helps to catch squares with gradient shading
            if( l == 0 && canny == 1 ) {
                // apply Canny. Take the upper threshold from slider
                // and set the lower to 0 (which forces edges merging)
                cv::Canny(gray0, gray, 0, thresh, 5);
                // dilate canny output to remove potent5ial holes between edge segments
                //cv::dilate(gray, gray, cv::Mat(), cv::Point(-1,-1));
                cv::dilate(gray, gray, cv::Mat(), cv::Point(-1,-1), 2, 1, 1); // 3x3 kernel
            }else{
                // apply threshold if l!=0:
                // tgray(x,y) = gray(x,y) < (l+1)*255/N ? 255 : 0
                gray = gray0 >= (l+1)*255/N;
            }
            // find contours and store them all as a list
            cv::findContours(gray, contours, cv::RETR_LIST, cv::CHAIN_APPROX_SIMPLE);
            //cv::drawContours(image,contours, -1, cv::Scalar(0), 1); //(0): in white
            vector<cv::Point> approx;
            // test each contour
            for( size_t i = 0; i < contours.size(); i++ ) {
                // approximate contour with accuracy proportional to the contour perimeter
                cv::approxPolyDP(cv::Mat(contours[i]), approx, arcLength(cv::Mat(contours[i]), true)*0.02, true);
                
                // square contours should have 4 vertices after approximation relatively large area (to filter out noisy contours) and be convex.
                // Note: absolute value of an area is used because area may be positive or negative - in accordance with the contour orientation
                double area = fabs(cv::contourArea(cv::Mat(approx)));
                BOOL isConvex = cv::isContourConvex(cv::Mat(approx));
                if( approx.size() == 4 && area> 500 && area < 0.9*gray.cols*gray.rows && isConvex ) {
                    double maxCosine = 0;
                    for( int j = 2; j < 5; j++ ) {
                        // find the maximum cosine of the angle between joint edges
                        double cosine = fabs(angle(approx[j%4], approx[j-2], approx[j-1]));
                        maxCosine = MAX(maxCosine, cosine);
                    }
                    // if cosines of all angles are small (all angles are ~90 degree)
                    // then write quandrange vertices to resultant sequence
                    if( maxCosine < tolerance ) squares.push_back(approx);
                }
            }
        }
    }
}

// findLargestSquare: find the largest square within a set of squares
void findMaxSquare(const vector<vector<cv::Point> >& squares, vector<cv::Point>& biggest_square){
    if (squares.size()<1){
        cout << "findLargestSquare !!! No squares detect, nothing to do." << endl;
        return;
    }
    int max_width = 0;
    int max_height = 0;
    int max_square_idx = 0;
    for (size_t i = 0; i < squares.size(); i++){
        // Convert a set of 4 unordered Points into a meaningful cv::Rect structure.
        cv::Rect rectangle = cv::boundingRect(cv::Mat(squares[i]));
        //cout << "find_largest_square: #" << i << " rectangle x:" << rectangle.x << " y:" << rectangle.y << " " << rectangle.width << "x" << rectangle.height << endl;
        // Store the index position of the biggest square found
        if ((rectangle.width >= max_width) && (rectangle.height >= max_height)){
            max_width = rectangle.width;
            max_height = rectangle.height;
            max_square_idx = i;
        }
    }

    biggest_square = squares[max_square_idx];
}
/*
 void findSquaresSimple(cv::Mat& src, vector<vector<cv::Point> >& squares){
 cv::Mat src_gray;
 cv::cvtColor(src, src_gray, cv::COLOR_BGR2GRAY);
 
 // Blur helps to decrease the amount of detected edges
 cv::Mat filtered;
 cv::blur(src_gray, filtered, cv::Size(3, 3));
 //cv::imwrite("out_blur.jpg", filtered);
 
 // Detect edges
 cv::Mat edges;
 int thresh = 100;
 cv::Canny(filtered, edges, thresh, thresh*3, 3);
 //cv::imwrite("out_edges.jpg", edges);
 
 // Dilate helps to connect nearby line segments
 cv::Mat dilated_edges;
 cv::dilate(edges, dilated_edges, cv::Mat(), cv::Point(-1, -1), 2, 1, 1); // default 3x3 kernel
 //cv::imwrite("out_dilated.jpg", dilated_edges);
 
 // Find contours and store them in a list
 vector<vector<cv::Point> > contours;
 cv::findContours(dilated_edges, contours, cv::RETR_LIST, cv::CHAIN_APPROX_SIMPLE);
 //cv::drawContours(src,contours, -1, cv::Scalar(0), 1); //(0): in black
 // -1:all contours, // (255,255,0): in white, 2: thickness
 
 // Test contours and assemble squares out of them
 vector<cv::Point> approx;
 for (size_t i = 0; i < contours.size(); i++) {
 // approximate contour with accuracy proportional to the contour perimeter
 cv::approxPolyDP(cv::Mat(contours[i]), approx, cv::arcLength(cv::Mat(contours[i]), true)*0.02, true);
 
 // Note: absolute value of an area is used because area may be positive or negative
 //- in accordance with the contour orientation
 if (approx.size() == 4 && fabs(contourArea(cv::Mat(approx))) > 1000 &&
 cv::isContourConvex(cv::Mat(approx))) {
 double maxCosine = 0;
 for (int j = 2; j < 5; j++) {
 double cosine = fabs(angle(approx[j%4], approx[j-2], approx[j-1]));
 maxCosine = MAX(maxCosine, cosine);
 }
 if (maxCosine < 0.5) squares.push_back(approx);
 }
 }
 }*/

@end
