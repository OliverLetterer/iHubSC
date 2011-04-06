//
//  GHTableViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 06.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GHTableViewController : UITableViewController {
@private
    NSMutableDictionary *_cachedHeightsDictionary;
}

@property (nonatomic, retain) NSMutableDictionary *cachedHeightsDictionary;

@property (nonatomic, readonly) UITableViewCell *dummyCell;

- (UITableViewCell *)dummyCellWithText:(NSString *)text;
- (CGFloat)heightForDescription:(NSString *)description;

@end




@interface GHTableViewController (GHHeightCaching)

- (void)cacheHeight:(CGFloat)height forRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)cachedHeightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isHeightCachedForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
