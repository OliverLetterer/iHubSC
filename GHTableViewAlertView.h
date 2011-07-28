//
//  UITableViewAlert.h
//  ExampleApp
//  
//  Created by docmorelli on 30.01.11.
//  Copyright 2011 Home. All rights reserved.
//  

#import <Foundation/Foundation.h>
#import "GHTableViewAlertViewTableViewBackgroundView.h"
#import "GHTableViewAlertViewTableViewCell.h"

@interface GHTableViewAlertView : UIAlertView {
	UITableView *_tableView;
}

@property (nonatomic, retain, readonly) UITableView *tableView;

@end
