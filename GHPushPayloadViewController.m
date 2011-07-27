//
//  GHPushPayloadViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 14.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPushPayloadViewController.h"
#import "GHDescriptionTableViewCell.h"
#import "GHViewCommitViewController.h"

@implementation GHPushPayloadViewController

@synthesize payload=_payload, repository=_repository;

#pragma mark - setters and getters

- (void)setPayload:(GHPushPayload *)payload {
    if (payload != _payload) {
        _payload = payload;
        [self cachePayloadHeights];
        [self.tableView reloadData];
    }
}

#pragma mark - Initialization

- (id)initWithPayload:(GHPushPayload *)payload onRepository:(NSString *)repository {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.payload = payload;
        self.repository = repository;
        self.title = NSLocalizedString(@"Push", @"");
    }
    return self;
}

#pragma mark - Memory management


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - instance methods

- (void)cachePayloadHeights {
    NSInteger i = 0;
    for (GHCommitMessage *message in self.payload.commits) {
        [self cacheHeight:[GHDescriptionTableViewCell heightWithContent:message.message] forRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] ];
        i++;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.payload.commits count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
    GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    GHCommitMessage *message = [self.payload.commits objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ committed %@", @""), message.name, message.head];
    cell.descriptionLabel.text = message.message;
    cell.imageView.image = [UIImage imageNamed:@"DefaultUserImage.png"];
    
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
    GHCommitMessage *message = [self.payload.commits objectAtIndex:indexPath.row];
    
    GHViewCommitViewController *commitViewController = [[GHViewCommitViewController alloc] initWithRepository:self.repository
                                                                                                      commitID:message.head];
    commitViewController.branchHash = self.payload.head;
    [self.navigationController pushViewController:commitViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self cachedHeightForRowAtIndexPath:indexPath];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_payload forKey:@"payload"];
    [encoder encodeObject:_repository forKey:@"repository"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _payload = [decoder decodeObjectForKey:@"payload"];
        _repository = [decoder decodeObjectForKey:@"repository"];
    }
    return self;
}

@end
