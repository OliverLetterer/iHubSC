//
//  GHPDiffViewTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 03.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPDefaultTableViewCell.h"
#import "GHPDiffView.h"

@interface GHPDiffViewTableViewCell : UITableViewCell {
@private
    GHPDiffView *_diffView;
}

@property (nonatomic, retain) GHPDiffView *diffView;

@end
