//
//  GHPTeamsViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPDataArrayViewController.h"

@interface GHPTeamsViewController : GHPDataArrayViewController <NSCoding> {
@private
    NSString *_organizationName;
}

@property (nonatomic, copy) NSString *organizationName;

- (id)initWithOrganizationName:(NSString *)organizationName;

@end
