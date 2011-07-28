//
//  UITableViewAlertViewTableViewCell.h
//  ExampleApp
//
//  Created by Oliver Letterer on 30.01.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewAlertViewTableViewCellSeperatorView.h"


@interface GHTableViewAlertViewTableViewCell : UITableViewCell {
	UIActivityIndicatorView *_activityIndicatorView;
	GHTableViewAlertViewTableViewCellSeperatorView *_seperatorView;
}

@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicatorView;

@end
