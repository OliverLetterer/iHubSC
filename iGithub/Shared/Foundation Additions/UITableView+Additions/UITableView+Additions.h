//
//  UITableView+Additions.h
//  iGithub
//
//  Created by Oliver Letterer on 08.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UITableView (UITableViewReloadingAdditions)

- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;
- (BOOL)containsIndexPath:(NSIndexPath *)indexPath;

@end
