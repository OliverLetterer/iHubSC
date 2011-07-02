//
//  UITableViewCell+GHHeight.m
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "UITableViewCell+GHHeight.h"


@implementation UITableViewCell (GHHeight)

+ (CGFloat)heightWithContent:(NSString *)content {
    return UITableViewAutomaticDimension;
}

@end
