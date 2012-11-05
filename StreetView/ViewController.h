//
//  ViewController.h
//  StreetView
//
//  Created by Oliver Rickard on 03/11/2012.
//  Copyright (c) 2012 Ruwnay20. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import "JCTiledPDFScrollView.h"

@interface ViewController : UIViewController <JCTileSource, JCTiledScrollViewDelegate> {
    NSDate *lastRequestDate;
}

@property (strong, nonatomic) JCTiledScrollView *scrollView;

@end
