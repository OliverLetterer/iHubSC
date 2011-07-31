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

@implementation GHCreateRepositoryViewController
@synthesize delegate=_delegate;
@synthesize createCell=_createCell;

#pragma mark - Initialization

- (id)init {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
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

- (void)viewDidUnload {
    [super viewDidUnload];
    _createCell = nil;
}

#pragma mark - target actions

- (void)publicSwitchChanged:(UISwitch *)sender {
    if (sender.isOn) {
        self.createCell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
    } else {
        self.createCell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
    }
}

#pragma mark - instance methods

- (void)createRepository {
    [GHAPIRepositoryV3 createRepositoryWithName:self.createCell.titleTextField.text 
                                    description:self.createCell.descriptionTextField.text 
                                         public:self.createCell.publicSwitch.isOn 
                              completionHandler:^(GHAPIRepositoryV3 *repository, NSError *error) {
                                  if (error) {
                                      [self handleError:error];
                                  } else {
                                      [self.delegate createRepositoryViewController:self didCreateRepository:repository];
                                  }
                              }];
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
    static NSString *CellIdentifier = @"Cell";
    
    GHCreateRepositoryTableViewCell *cell = (GHCreateRepositoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GHCreateRepositoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                       reuseIdentifier:CellIdentifier];
        
        cell.titleTextField.delegate = self;
        cell.descriptionTextField.delegate = self;
        [cell.publicSwitch addTarget:self action:@selector(publicSwitchChanged:) 
                    forControlEvents:UIControlEventValueChanged];
    }
    
    // Configure the cell...
    
    if (cell.publicSwitch.isOn) {
        cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
    }
    
    self.createCell = cell;
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 125.0f;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {  
    if (textField == self.createCell.titleTextField) {
        [self.createCell.descriptionTextField becomeFirstResponder];
    } else if (textField == self.createCell.descriptionTextField) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
