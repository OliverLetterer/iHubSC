//
//  GHTableViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 06.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHTableViewController.h"
#import "GithubAPI.h"
#import "GHNewsFeedItemTableViewCell.h"

@implementation GHTableViewController

@synthesize cachedHeightsDictionary=_cachedHeightsDictionary;

#pragma mark - setters and getters

- (UITableViewCell *)dummyCell {
    static NSString *CellIdentifier = @"DummyCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = @"__DUMMY__";
    // Configure the cell...
    
    return cell;
}

#pragma mark - instance methods

- (UITableViewCell *)dummyCellWithText:(NSString *)text {
    NSString *CellIdentifier = @"DummyCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = text;
    
    return cell;
}

- (CGFloat)heightForDescription:(NSString *)description {
    CGSize newSize = [description sizeWithFont:[UIFont systemFontOfSize:12.0] 
                             constrainedToSize:CGSizeMake(222.0f, MAXFLOAT)
                                 lineBreakMode:UILineBreakModeWordWrap];
    
    return newSize.height < 21 ? 21 : newSize.height;
}

- (void)handleError:(NSError *)error {
    if (error != nil) {
        DLog(@"%@", error);
        
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
                                                         message:[error localizedDescription] 
                                                        delegate:nil 
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                               otherButtonTitles:nil]
                              autorelease];
        [alert show];
    }
}

- (void)updateImageViewForCell:(GHNewsFeedItemTableViewCell *)cell 
                   atIndexPath:(NSIndexPath *)indexPath 
                withGravatarID:(NSString *)gravatarID {
    
    UIImage *gravatarImage = [UIImage cachedImageFromGravatarID:gravatarID];
    
    if (gravatarImage) {
        cell.imageView.image = gravatarImage;
        [cell.activityIndicatorView stopAnimating];
    } else {
        [cell.activityIndicatorView startAnimating];
        
        [UIImage imageFromGravatarID:gravatarID 
               withCompletionHandler:^(UIImage *image, NSError *error, BOOL didDownload) {
                   if ([self.tableView containsIndexPath:indexPath]) {
                       [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
                   }
               }];
    }
}

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        // Custom initialization
        self.cachedHeightsDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_cachedHeightsDictionary release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.scrollsToTop = YES;
    self.tableView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    self.tableView.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0];
    self.tableView.rowHeight = 71.0;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end



@implementation GHTableViewController (GHHeightCaching)

- (void)cacheHeight:(CGFloat)height forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.cachedHeightsDictionary setObject:[NSNumber numberWithFloat:height] forKey:indexPath];
}

- (CGFloat)cachedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[self.cachedHeightsDictionary objectForKey:indexPath] floatValue];
}

- (BOOL)isHeightCachedForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cachedHeightsDictionary objectForKey:indexPath] != nil;
}

@end

