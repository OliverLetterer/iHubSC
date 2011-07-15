//
//  GHPSearchScopeTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 10.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPDefaultTableViewCell.h"

@class GHPSearchScopeTableViewCell;

@protocol GHPSearchScopeTableViewCellDelegate <NSObject>

- (void)searchScopeTableViewCell:(GHPSearchScopeTableViewCell *)searchScopeTableViewCell didSelectButtonAtIndex:(NSUInteger)index;

@end

@interface GHPSearchScopeTableViewCell : GHPDefaultTableViewCell {
@private
    NSMutableArray *_buttons;
    NSUInteger _currentSelectedButtonIndex;
    
    id<GHPSearchScopeTableViewCellDelegate> _delegate;
}

@property (nonatomic, assign) id<GHPSearchScopeTableViewCellDelegate> delegate;

- (id)initWithButtonTitles:(NSArray *)buttonTitles reuseIdentifier:(NSString *)reuseIdentifier;
- (NSString *)titleForButtonAtIndex:(NSUInteger)index;

- (void)buttonClicked:(UIButton *)button;

@end
