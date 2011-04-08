//
//  UITableView+Additions.m
//  iGithub
//
//  Created by Oliver Letterer on 08.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "UITableView+Additions.h"


@implementation UITableView (UITableViewReloadingAdditions)

- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
    [self reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                withRowAnimation:animation];
}

- (BOOL)containsIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < [self numberOfSections]) {
        if (indexPath.row < [self numberOfRowsInSection:indexPath.section]) {
            return YES;
        }
    }
    return NO;
}

@end
