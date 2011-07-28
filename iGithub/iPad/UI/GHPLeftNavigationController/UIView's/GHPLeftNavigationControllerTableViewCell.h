//
//  GHPLeftNavigationControllerTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 30.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPEdgedLineView.h"

@interface GHPLeftNavigationControllerTableViewCell : UITableViewCell {
@private
    GHPEdgedLineView *_lineView;
}

@property (nonatomic, retain) GHPEdgedLineView *lineView;

- (void)setItemImage:(UIImage *)itemImage;

@end
