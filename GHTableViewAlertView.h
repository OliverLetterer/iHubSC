//
//  UITableViewAlert.h
//  ExampleApp
//  
//  Created by docmorelli on 30.01.11.
//  Copyright 2011 Home. All rights reserved.
//  

#import <Foundation/Foundation.h>

@interface GHTableViewAlertView : UIAlertView {
	UITableView *_tableView;
}

@property (nonatomic, readonly) UITableView *tableView;

@end
