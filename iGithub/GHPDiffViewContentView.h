//
//  GHPDiffViewContentView.h
//  iGithub
//
//  Created by Oliver Letterer on 03.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GHPDiffViewContentView : UIView {
@private
    NSString *_diffString;
    CGFloat _width;
}

@property (nonatomic, copy) NSString *diffString;
@property (nonatomic, readonly) CGFloat width;

@end
