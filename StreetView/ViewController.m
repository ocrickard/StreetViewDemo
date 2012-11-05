//
//  ViewController.m
//  StreetView
//
//  Created by Oliver Rickard on 03/11/2012.
//  Copyright (c) 2012 Ruwnay20. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"

#define cp(x, y) CGPointMake(x, y)

@interface ViewController () {
    JCTiledScrollView *_scrollView;
}

@end

@implementation ViewController
@synthesize scrollView = _scrollView;

+ (CATransform3D)rectToQuad:(CGRect)rect
                    quadTLX:(CGFloat)x1a
                    quadTLY:(CGFloat)y1a
                    quadTRX:(CGFloat)x2a
                    quadTRY:(CGFloat)y2a
                    quadBLX:(CGFloat)x3a
                    quadBLY:(CGFloat)y3a
                    quadBRX:(CGFloat)x4a
                    quadBRY:(CGFloat)y4a
{
    CGFloat X = rect.origin.x;
    CGFloat Y = rect.origin.y;
    CGFloat W = rect.size.width;
    CGFloat H = rect.size.height;
    
    CGFloat y21 = y2a - y1a;
    CGFloat y32 = y3a - y2a;
    CGFloat y43 = y4a - y3a;
    CGFloat y14 = y1a - y4a;
    CGFloat y31 = y3a - y1a;
    CGFloat y42 = y4a - y2a;
    
    CGFloat a = -H*(x2a*x3a*y14 + x2a*x4a*y31 - x1a*x4a*y32 + x1a*x3a*y42);
    CGFloat b = W*(x2a*x3a*y14 + x3a*x4a*y21 + x1a*x4a*y32 + x1a*x2a*y43);
    CGFloat c = H*X*(x2a*x3a*y14 + x2a*x4a*y31 - x1a*x4a*y32 + x1a*x3a*y42) - H*W*x1a*(x4a*y32 - x3a*y42 + x2a*y43) - W*Y*(x2a*x3a*y14 + x3a*x4a*y21 + x1a*x4a*y32 + x1a*x2a*y43);
    
    CGFloat d = H*(-x4a*y21*y3a + x2a*y1a*y43 - x1a*y2a*y43 - x3a*y1a*y4a + x3a*y2a*y4a);
    CGFloat e = W*(x4a*y2a*y31 - x3a*y1a*y42 - x2a*y31*y4a + x1a*y3a*y42);
    CGFloat f = -(W*(x4a*(Y*y2a*y31 + H*y1a*y32) - x3a*(H + Y)*y1a*y42 + H*x2a*y1a*y43 + x2a*Y*(y1a - y3a)*y4a + x1a*Y*y3a*(-y2a + y4a)) - H*X*(x4a*y21*y3a - x2a*y1a*y43 + x3a*(y1a - y2a)*y4a + x1a*y2a*(-y3a + y4a)));
    
    CGFloat g = H*(x3a*y21 - x4a*y21 + (-x1a + x2a)*y43);
    CGFloat h = W*(-x2a*y31 + x4a*y31 + (x1a - x3a)*y42);
    CGFloat i = W*Y*(x2a*y31 - x4a*y31 - x1a*y42 + x3a*y42) + H*(X*(-(x3a*y21) + x4a*y21 + x1a*y43 - x2a*y43) + W*(-(x3a*y2a) + x4a*y2a + x2a*y3a - x4a*y3a - x2a*y4a + x3a*y4a));
    
    if(fabs(i) < 0.00001)
    {
        i = 0.00001;
    }
    
    CATransform3D t = CATransform3DIdentity;
    
    t.m11 = a / i;
    t.m12 = d / i;
    t.m13 = 0;
    t.m14 = g / i;
    t.m21 = b / i;
    t.m22 = e / i;
    t.m23 = 0;
    t.m24 = h / i;
    t.m31 = 0;
    t.m32 = 0;
    t.m33 = 1;
    t.m34 = 0;
    t.m41 = c / i;
    t.m42 = f / i;
    t.m43 = 0;
    t.m44 = i / i;
    
    return t;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 20.f)];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.view = view;
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.scrollView = [[JCTiledScrollView alloc] initWithFrame:self.view.bounds contentSize:CGSizeMake(320*10, self.view.bounds.size.height)];
    
    self.scrollView.dataSource = self;
    self.scrollView.tiledScrollViewDelegate = self;
    self.scrollView.zoomScale = 1.0f;
    self.scrollView.contentMode = UIViewContentModeScaleAspectFill;
    self.scrollView.scrollView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.scrollView.levelsOfZoom = 5;
    self.scrollView.levelsOfDetail = 1;
    self.scrollView.scrollView.minimumZoomScale = 1.f;
    self.scrollView.scrollView.bouncesZoom = NO;
    self.scrollView.scrollView.bounces = NO;
    
    [self.view addSubview:self.scrollView];
    
    [self tiledScrollViewDidZoom:self.scrollView]; //force the detailView to update the frist time
    
    [self.scrollView.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    [self becomeFirstResponder];
}

- (void)viewDidUnload
{
    _scrollView = nil;
    
    [super viewDidUnload];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint offset = self.scrollView.scrollView.contentOffset;
        
        offset.x = offset.x / self.scrollView.zoomScale;
        offset.y = offset.y / self.scrollView.zoomScale;
        
        NSLog(@"contentOffset:(%f,%f) self.scrollView.contentSize:(%f,%f) self.scrollView.scrollView.contentSize:(%f,%f)", offset.x, offset.y, self.scrollView.contentSize.width, self.scrollView.contentSize.height, self.scrollView.scrollView.contentSize.width, self.scrollView.scrollView.contentSize.height);
        
        if(offset.x > self.scrollView.contentSize.width - self.view.bounds.size.width) {
            self.scrollView.scrollView.contentOffset = CGPointMake(offset.x*self.scrollView.zoomScale - (self.scrollView.contentSize.width - self.view.bounds.size.width)*self.scrollView.zoomScale, offset.y*self.scrollView.zoomScale);
        }
        NSLog(@"scale:%f", self.scrollView.zoomScale);
    }
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Responder

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake)
    {
        [self.scrollView removeAllAnnotations];
    }
}

#pragma mark - JCTiledScrollViewDelegate

- (void)tiledScrollViewDidZoom:(JCTiledScrollView *)scrollView
{
    
}

- (void)tiledScrollView:(JCTiledScrollView *)scrollView didReceiveSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    //CGPoint tapPoint = [gestureRecognizer locationInView:(UIView *)scrollView.tiledView];
    //Do something?
}

- (void)tiledScrollView:(JCTiledScrollView *)scrollView didReceiveDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    //CGPoint tapPoint = [gestureRecognizer locationInView:(UIView *)scrollView.tiledView];
}


- (JCAnnotationView *)tiledScrollView:(JCTiledScrollView *)scrollView viewForAnnotation:(id<JCAnnotation>)annotation {
    //Do something?
    return nil;
}
#pragma mark - JCTileSource

- (UIImage *)tiledScrollView:(JCTiledScrollView *)scrollView imageForRow:(NSInteger)row column:(NSInteger)column scale:(NSInteger)scale
{
    float fov = 45.f / scale;
    
    float heading = fmodf(column*fov, 360.f);
    float pitch = (scale - row)*fov;
    
    if(lastRequestDate) {
        while(fabsf([lastRequestDate timeIntervalSinceNow]) < 0.1f) {
            //continue only if the time interval is greater than 0.1 seconds
        }
    }
    
    lastRequestDate = [NSDate date];
    
    int resolution = (scale > 1.f) ? 640 : 200;
    
    NSString *path = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/streetview?size=%dx%d&location=40.720032,-73.988354&fov=%f&heading=%f&pitch=%f&sensor=false", resolution, resolution, fov, heading, pitch];
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:path] options:0 error:&error];
    if(error) {
        NSLog(@"Error downloading image:%@", error);
    }
    UIImage *image = [UIImage imageWithData:data];
    
    //Distort image using GPUImage
    {
        //This is where you should try to transform the image.  I messed around
        //with the math for awhile, and couldn't get it.  Therefore, this is left
        //as an exercise for the reader... :)
        
        /*
        GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:image];
        GPUImageTransformFilter *stillImageFilter = [[GPUImageTransformFilter alloc] init];
        [stillImageFilter forceProcessingAtSize:image.size];
        
        //This is actually based on some math, but doesn't work...
//        float xOffset = 200.f;
//        CATransform3D transform = [ViewController rectToQuad:CGRectMake(0, 0, image.size.width, image.size.height) quadTLX:-xOffset quadTLY:0 quadTRX:(image.size.width+xOffset) quadTRY:0.f quadBLX:0.f quadBLY:image.size.height quadBRX:image.size.width quadBRY:image.size.height];
//        [(GPUImageTransformFilter *)stillImageFilter setTransform3D:transform];
        
        //This is me playing guess and check...
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = fabsf(pitch) / 60.f * 0.3f;
        
        transform = CATransform3DRotate(transform, pitch*M_PI/180.f, 1.f, 0.f, 0.f);
        transform = CATransform3DScale(transform, 1.f/cosf(pitch*M_PI/180.f), sinf(pitch*M_PI/180.f) + 1.f, 1.f);
        transform = CATransform3DTranslate(transform, 0.f, 0.1f * sinf(pitch*M_PI/180.f), 0.f);
        
        [stillImageFilter setTransform3D:transform];
        
        
        [stillImageSource addTarget:stillImageFilter];
        [stillImageFilter prepareForImageCapture];
        [stillImageSource processImage];
        
        image = [stillImageFilter imageFromCurrentlyProcessedOutput];
         */
    }
    
    return image;
}


@end
