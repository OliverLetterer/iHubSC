//
//  GHSearchViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 20.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface GHSearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
@private
    UISearchBar *_searchBar;
    UISearchDisplayController *_mySearchDisplayController;
    CAGradientLayer *_backgroundGradientLayer;
    
    NSString *_searchString;
}

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) CAGradientLayer *backgroundGradientLayer;
@property (nonatomic, copy) NSString *searchString;

@end
