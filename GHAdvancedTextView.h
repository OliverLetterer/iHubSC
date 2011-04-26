//
//  GHAdvancedTextView.h
//  iGithub
//
//  Created by Oliver Letterer on 23.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHAdvancedTextViewInternalCoreTextView.h"


@interface GHAdvancedTextView : UIScrollView {
@private
    GHAdvancedTextViewInternalCoreTextView *_coreTextView;
}

@property (nonatomic, retain) GHAdvancedTextViewInternalCoreTextView *coreTextView;

@end
