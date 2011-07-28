//
//  GHPDataArrayViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 07.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@interface GHPDataArrayViewController : GHTableViewController <NSCoding> {
@private
    NSMutableArray *_dataArray;
}

@property (nonatomic, retain) NSMutableArray *dataArray;
@property (nonatomic, readonly) NSString *emptyArrayErrorMessage;

- (void)setDataArray:(NSMutableArray *)dataArray nextPage:(NSUInteger)nextPage;
- (void)appendDataFromArray:(NSMutableArray *)array nextPage:(NSUInteger)nextPage;

- (void)cacheDataArrayHeights;

@end
