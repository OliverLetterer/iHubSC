//
//  GHUsersNewsFeedsViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 06.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHNewsFeedViewController.h"



/**
 @class     GHUsersNewsFeedsViewController
 @abstract  <#abstract comment#>
 */
@interface GHUsersNewsFeedsViewController : GHNewsFeedViewController {
@private
    UISegmentedControl *_segmentedControl;
    
    BOOL _downloadDataInViewDidLoad;
}

- (id)initAndDownloadData;

@property (nonatomic, readonly) UISegmentedControl *segmentedControl;

- (void)segmentControlValueChanged:(UISegmentedControl *)segmentedControl;

@end
