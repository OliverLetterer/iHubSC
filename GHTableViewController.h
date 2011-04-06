//
//  GHTableViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 06.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GHTableViewController : UITableViewController {
    
}

@property (nonatomic, readonly) UITableViewCell *dummyCell;

- (UITableViewCell *)dummyCellWithText:(NSString *)text;
- (CGFloat)heightForDescription:(NSString *)description;

@end
