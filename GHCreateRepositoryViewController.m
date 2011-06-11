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

#pragma mark - Memory management

- (void)dealloc {
    [_createCell release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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

    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                           target:self 
                                                                                           action:@selector(cancelButtonClicked:)]
                                             autorelease];
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Create", @"") 
                                                                               style:UIBarButtonItemStyleDone 
                                                                              target:self 
                                                                              action:@selector(createButtonClicked:)]
                                              autorelease];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [_createCell release];
    _createCell = nil;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
        cell = [[[GHCreateRepositoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                       reuseIdentifier:CellIdentifier] 
                autorelease];
        
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 125.0;
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
