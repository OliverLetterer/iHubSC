//
//  GHColorAlertView.m
//  iGithub
//
//  Created by Oliver Letterer on 06.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHColorAlertView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GHColorAlertView

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    if (self = [super initWithTitle:title message:@"\n\n\n\n\n\n" delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil]) {
        
        _redSlider = [[UISlider alloc] initWithFrame:CGRectZero];
        [_redSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        _redSlider.minimumTrackTintColor = [UIColor redColor];
        
        _greenSlider = [[UISlider alloc] initWithFrame:CGRectZero];
        [_greenSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        _greenSlider.minimumTrackTintColor = [UIColor greenColor];
        
        _blueSlider = [[UISlider alloc] initWithFrame:CGRectZero];
        [_blueSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        _blueSlider.minimumTrackTintColor = [UIColor blueColor];
        
        _previewView = [[UIView alloc] initWithFrame:CGRectZero];
        _previewView.layer.borderColor = [UIColor whiteColor].CGColor;
        _previewView.layer.borderWidth = 1.0f;
        
        [self addSubview:_previewView];
        [self addSubview:_redSlider];
        [self addSubview:_greenSlider];
        [self addSubview:_blueSlider];
        
        self.selectedColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f];
    }
    return self;
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    if (CGColorSpaceGetModel(CGColorGetColorSpace(selectedColor.CGColor)) == kCGColorSpaceModelMonochrome) {
        const CGFloat *clr = CGColorGetComponents(selectedColor.CGColor);
        [_redSlider setValue:clr[0] animated:YES];
        [_greenSlider setValue:clr[0] animated:YES];
        [_blueSlider setValue:clr[0] animated:YES];
    } else if (CGColorSpaceGetModel(CGColorGetColorSpace(selectedColor.CGColor)) == kCGColorSpaceModelRGB) {
        const CGFloat *clr = CGColorGetComponents(selectedColor.CGColor);
        [_redSlider setValue:clr[0] animated:YES];
        [_greenSlider setValue:clr[1] animated:YES];
        [_blueSlider setValue:clr[2] animated:YES];
    }
    _previewView.backgroundColor = selectedColor;
}

- (UIColor *)selectedColor {
    return [UIColor colorWithRed:_redSlider.value green:_greenSlider.value blue:_blueSlider.value alpha:1.0f];
}

- (void)sliderValueChanged:(UISlider *)sender {
    self.selectedColor = self.selectedColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat top = 35.0f;
    CGFloat sliderHeight = 30.0f;
    
    _redSlider.frame = CGRectMake(20.0f, top, CGRectGetWidth(self.bounds) - 40.0f, sliderHeight);
    top += sliderHeight;
    _greenSlider.frame = CGRectMake(20.0f, top, CGRectGetWidth(self.bounds) - 40.0f, sliderHeight);
    top += sliderHeight;
    _blueSlider.frame = CGRectMake(20.0f, top, CGRectGetWidth(self.bounds) - 40.0f, sliderHeight);
    top += sliderHeight + 5.0f;
    
    _previewView.frame = CGRectMake(20.0f, top, CGRectGetWidth(self.bounds) - 40.0f, 40.0f);
}

@end
