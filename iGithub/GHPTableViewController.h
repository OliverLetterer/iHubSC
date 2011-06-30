//
//  GHPTableViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 24.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPDefaultTableViewCellBackgroundView.h"
#import "GHPDefaultTableViewCell.h"

@interface GHPTableViewController : UITableViewController {
@private
    
}

- (GHPDefaultTableViewCell *)defaultTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath withReuseIdentifier:(NSString *)CellIdentifier;

@end
