//
//  UITableViewAlert.m
//  ExampleApp
//
//  Created by Oliver Letterer on 30.01.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHTableViewAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import "GHTableViewAlertViewTableViewBackgroundView.h"
#import "GHTableViewAlertViewTableViewCell.h"


@implementation GHTableViewAlertView

@synthesize tableView=_tableView;

#pragma mark -
#pragma mark instance methods

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    if (self = [super initWithTitle:title message:@"\n\n\n\n\n\n\n" delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil]) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(11.0f, 50.0f, 261.0f, 147.0f) style:UITableViewStylePlain];
		_tableView.layer.cornerRadius = 5.0f;
		_tableView.separatorColor = [UIColor colorWithWhite:175.0f/255.0f alpha:0.0f];
		_tableView.backgroundColor = [UIColor whiteColor];
		[self addSubview:_tableView];
        _tableView.backgroundView = [[GHTableViewAlertViewTableViewBackgroundView alloc] initWithFrame:_tableView.bounds];
		
		UIColor *darkShadowColor = [UIColor colorWithWhite:0.5 alpha:0.5];
		UIColor *lightShadowColor = [UIColor colorWithWhite:0.0 alpha:0.0];
		
		CAGradientLayer *layer = [CAGradientLayer layer];
		layer.colors = [NSArray arrayWithObjects:
						(__bridge id)darkShadowColor.CGColor, (__bridge id)lightShadowColor.CGColor,
						(__bridge id)lightShadowColor.CGColor, (__bridge id)darkShadowColor.CGColor, 
						nil];
		layer.locations = [NSArray arrayWithObjects:
						   [NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:0.05f],
						   [NSNumber numberWithFloat:0.98f], [NSNumber numberWithFloat:1.0f],
						   nil];
		layer.frame = _tableView.frame;
		layer.cornerRadius = _tableView.layer.cornerRadius;
		[self.layer addSublayer:layer];
    }
    return self;
}

//- (id)initWithTitle:(NSString *)title content:(NSArray *)content delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle {
//	if ((self = [super initWithTitle:title message:@"\n\n\n\n\n\n\n" delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil])) {
//		_dismissIfRowSelected = YES;
//		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(11, 50, 261, 147) style:UITableViewStylePlain];
//		_tableView.layer.cornerRadius = 5.0;
//		_tableView.dataSource = self;
//		_tableView.delegate = self;
//		_tableView.separatorColor = [UIColor colorWithWhite:175.0/255.0 alpha:0.0];
//		_tableView.backgroundColor = [UIColor whiteColor];
//		[self addSubview:_tableView];
//		if ([_tableView respondsToSelector:@selector(setBackgroundView:)]) {
//			_tableView.backgroundView = [[[UITableViewAlertViewTableViewBackgroundView alloc] initWithFrame:_tableView.bounds] autorelease];
//		}
//		
//		UIColor *darkShadowColor = [UIColor colorWithWhite:0.5 alpha:0.5];
//		UIColor *lightShadowColor = [UIColor colorWithWhite:0.0 alpha:0.0];
//		
//		CAGradientLayer *layer = [CAGradientLayer layer];
//		layer.colors = [NSArray arrayWithObjects:
//						(id)darkShadowColor.CGColor, (id)lightShadowColor.CGColor,
//						(id)lightShadowColor.CGColor, (id)darkShadowColor.CGColor, 
//						nil];
//		layer.locations = [NSArray arrayWithObjects:
//						   [NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.05],
//						   [NSNumber numberWithFloat:0.98], [NSNumber numberWithFloat:1.0],
//						   nil];
//		layer.frame = _tableView.frame;
//		layer.cornerRadius = _tableView.layer.cornerRadius;
//		[self.layer addSublayer:layer];
//		
//		self.content = content;
//		
//		self.myDelegate = delegate;
//	}
//	return self;
//}

//- (void)setIndexAnimating:(NSInteger)index {
//	[self.animatingIndexes setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInt:index]];
//	[self.tableView reloadData];
//}
//
//- (void)stopIndexAnimating:(NSInteger)index {
//	[self.animatingIndexes removeObjectForKey:[NSNumber numberWithInt:index]];
//	[self.tableView reloadData];
//}
//
//- (void)resetAnimatingIndexes {
//	self.animatingIndexes = [NSMutableDictionary dictionary];
//	[self.tableView reloadData];
//}

#pragma mark -
#pragma mark UIAlertViewDelegate

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//	[self dismissWithClickedButtonIndex:0 animated:YES];
//    [self.myDelegate alertViewDidCancel:self];
//}

#pragma mark -
#pragma mark UITableViewDelegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	return 45.0;
//}

#pragma mark -
#pragma mark UITableViewDataSource

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//	return [self.content count];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//	NSString *CellIdentifier = @"UITableViewAlertViewTableViewCell";
//	UITableViewAlertViewTableViewCell *cell = (UITableViewAlertViewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//	if (!cell) {
//		cell = [[[UITableViewAlertViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//		cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
//		cell.backgroundView.backgroundColor = [UIColor clearColor];
//	}
//	cell.textLabel.text = [self.content objectAtIndex:indexPath.row];
//	if ([[self.animatingIndexes objectForKey:[NSNumber numberWithInt:indexPath.row]] boolValue]) {
//		[cell.activityIndicatorView startAnimating];
//	}
//	return cell;
//}

@end
