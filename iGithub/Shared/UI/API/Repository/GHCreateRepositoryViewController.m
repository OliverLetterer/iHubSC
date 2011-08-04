//
//  GHCreateRepositoryViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 07.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCreateRepositoryViewController.h"
#import "GithubAPI.h"
#import "GHCreateRepositoryTableViewCell.h"
#import "GHPCreateRepositoryTableViewCell.h"

@implementation GHCreateRepositoryViewController
@synthesize delegate=_delegate;

#pragma mark - Initialization

- (id)init {
    if ((self = [super initWithStyle:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UITableViewStyleGrouped : UITableViewStylePlain])) {
        // Custom initialization
        self.title = NSLocalizedString(@"Create a Repository", @"");
    }
    return self;
}

#pragma mark - target actions

- (void)cancelButtonClicked:(UIBarButtonItem *)button {
    [self.delegate createRepositoryViewControllerDidCancel:self];
}

- (void)createButtonClicked:(UIBarButtonItem *)button {
    [self createRepository];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                           target:self 
                                                                                           action:@selector(cancelButtonClicked:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Create", @"") 
                                                                               style:UIBarButtonItemStyleDone 
                                                                              target:self 
                                                                              action:@selector(createButtonClicked:)];
}

#pragma mark - instance methods

- (void)createRepository {
    NSString *title = nil;
    NSString *description = nil;
    BOOL public = NO;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        GHPCreateRepositoryTableViewCell *cell = (GHPCreateRepositoryTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        title = cell.titleTextField.text;
        description = cell.descriptionTextField.text;
        public = cell.publicSwitch.isOn;
    } else {
        GHCreateRepositoryTableViewCell *cell = (GHCreateRepositoryTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        title = cell.titleTextField.text;
        description = cell.descriptionTextField.text;
        public = cell.publicSwitch.isOn;
    }
    
    [GHAPIRepositoryV3 createRepositoryWithName:title 
                                    description:description 
                                         public:public 
                              completionHandler:^(GHAPIRepositoryV3 *repository, NSError *error) {
                                  if (error) {
                                      [self handleError:error];
                                  } else {
                                      [self.delegate createRepositoryViewController:self didCreateRepository:repository];
                                  }
                              }];
}

#pragma mark - target actions

- (void)publicSwitchChanged:(id)sender {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        static NSString *CellIdentifier = @"GHPCreateRepositoryTableViewCell";
        
        GHPCreateRepositoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GHPCreateRepositoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                          reuseIdentifier:CellIdentifier];
            
            [cell.publicSwitch addTarget:self action:@selector(publicSwitchChanged:) 
                        forControlEvents:UIControlEventValueChanged];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        
        // Configure the cell...
        
        if (cell.publicSwitch.isOn) {
            cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
        }
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"Cell";
        
        GHCreateRepositoryTableViewCell *cell = (GHCreateRepositoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GHCreateRepositoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                          reuseIdentifier:CellIdentifier];
            
            [cell.publicSwitch addTarget:self action:@selector(publicSwitchChanged:) 
                        forControlEvents:UIControlEventValueChanged];
        }
        
        // Configure the cell...
        
        if (cell.publicSwitch.isOn) {
            cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
        }
        
        return cell;
    }
    
    return self.dummyCell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 125.0f;
}

@end
