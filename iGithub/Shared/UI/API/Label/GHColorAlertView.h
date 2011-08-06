//
//  GHColorAlertView.h
//  iGithub
//
//  Created by Oliver Letterer on 06.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GHColorAlertView : UIAlertView {
    UISlider *_redSlider;
    UISlider *_greenSlider;
    UISlider *_blueSlider;
    
    UIView *_previewView;
}

@property (nonatomic, assign) UIColor *selectedColor;

- (void)sliderValueChanged:(UISlider *)sender;

@end
