//
//  GHViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 20.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GHViewController : UIViewController <NSCoding> {
@private
    UIColor *_navigationTintColor;
}

@property (nonatomic, retain) UIColor *navigationTintColor;


@end
