//
//  GHNewsFeedViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 30.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GHNewsFeed, GHNewsFeedItemTableViewCell, GHNewsFeedItem;

@interface GHNewsFeedViewController : UITableViewController {
    UISegmentedControl *_segmentControl;
    GHNewsFeed *_newsFeed;
    NSDictionary *_issuesDictionary;
}

@property (nonatomic, retain) UISegmentedControl *segmentControl;
@property (nonatomic, retain) GHNewsFeed *newsFeed;

- (void)segmentControlValueChanged:(UISegmentedControl *)segmentControl;

- (UITableViewCell *)dummyCellWithText:(NSString *)text;
- (CGFloat)heightForGHFeedItemWithDescriptionTableViewCellForDescription:(NSString *)description;

@end
