//
//  GHCommitDiffViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 15.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GHPDiffView.h"
#import "GHViewController.h"

@interface GHCommitDiffViewController : GHViewController <UIScrollViewDelegate> {
@private
    NSString *_diffString;
    
    UIScrollView *_scrollView;
    GHPDiffView *_diffView;
}

@property (nonatomic, copy) NSString *diffString;

@property (nonatomic, retain) GHPDiffView *diffView;

- (id)initWithDiffString:(NSString *)diffString;

@end
