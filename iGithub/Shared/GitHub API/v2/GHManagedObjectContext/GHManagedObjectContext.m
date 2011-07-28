//
//  GHManagedObjectContext.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHManagedObjectContext.h"
#import "iGithubAppDelegate.h"

NSManagedObjectContext *GHSharedManagedObjectContext() {
    return [(iGithubAppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
}
