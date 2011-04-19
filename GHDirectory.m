//
//  GHDirectory.m
//  iGithub
//
//  Created by Oliver Letterer on 18.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHDirectory.h"
#import "GHFile.h"

@interface GHDirectory (private)

- (void)_parseFilesDictionary:(NSDictionary *)filesDictionary directories:(NSArray **)directories files:(NSArray **)files;
- (void)_dumpContentInString:(NSMutableString *)string level:(NSUInteger)level;
- (void)_sort;

@end


@implementation GHDirectory

@synthesize directories=_directories, files=_files;

- (NSComparisonResult)caseInsensitiveCompare:(GHDirectory *)aDirectory {
    return [self.lastNameComponent caseInsensitiveCompare:aDirectory.lastNameComponent];
}

- (GHFileSystemItemType)type {
    [self doesNotRecognizeSelector:_cmd];
    return GHFileSystemItemTypeFile;
}

- (NSString *)lastNameComponent {
    return [[_name componentsSeparatedByString:@"/"] lastObject];
}

- (NSString *)description {
    NSMutableString *returnString = [NSMutableString string];
    [self _dumpContentInString:returnString level:0];
    return returnString;
}

- (void)_sort {
    self.directories = [self.directories sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    self.files = [self.files sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (void)_dumpContentInString:(NSMutableString *)string level:(NSUInteger)level {
    NSMutableString *offset = [NSMutableString string];
    for (int i = 0; i < level; i++) {
        [offset appendString:@"\t"];
    }
    
    [string appendFormat:@"%@\"%@\" = {\n", offset, self.name];
    
    for (GHDirectory *directory in self.directories) {
        [directory _dumpContentInString:string level:level+1];
    }
    
    for (GHFile *file in self.files) {
        [string appendFormat:@"%@\t\"%@\" : \"%@\"\n", offset, file.name, file.hash];
    }
    [string appendFormat:@"%@}\n", offset];
}

#pragma mark - Initialization

- (id)initWithFilesDictionary:(NSDictionary *)dictionary name:(NSString *)name {
    if ((self = [super init])) {
        self.name = name;
        NSArray *files = nil;
        NSArray *dirs = nil;
        [self _parseFilesDictionary:dictionary directories:&dirs files:&files];
        
        self.files = files;
        self.directories = dirs;
        
        [self _sort];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_directories release];
    [_files release];
    
    [super dealloc];
}

#pragma mark - private

- (void)_parseFilesDictionary:(NSDictionary *)filesDictionary directories:(NSArray **)directories files:(NSArray **)files {
    if (directories == NULL || files == NULL) {
        return;
    }
    
    NSMutableDictionary *restDictionary = [NSMutableDictionary dictionary];
    
    NSMutableArray *myFilesArray = [NSMutableArray array];
    NSMutableArray *myDirectoriesArray = [NSMutableArray array];
    
    NSArray *allFiles = [filesDictionary allKeys];
    
    for (NSString *file in allFiles) {
        NSArray *components = [file componentsSeparatedByString:@"/"];
        if ([components count] == 1) {
            // well this is only one single files, lets create a file representation and add it to our files
            NSString *hash = [filesDictionary objectForKey:file];
            GHFile *newFile = [[[GHFile alloc] initWithName:file hash:hash] autorelease];
            [myFilesArray addObject:newFile];
        } else {
            NSString *hash = [filesDictionary objectForKey:file];
            // well this one contains more that a single file
            NSString *baseDirectoryName = [components objectAtIndex:0];
            NSMutableString *restFileName = [NSMutableString string];
            [components enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *component = (NSString *)obj;
                if (idx == 0) {
                    return ;
                }
                
                [restFileName appendFormat:@"%@/", component];
            }];
            [restFileName deleteCharactersInRange:NSMakeRange([restFileName length]-1, 1)];
            // now we have the rest of the file name
            
            NSMutableDictionary *tmpFilesDictionary = [restDictionary objectForKey:baseDirectoryName];
            if (!tmpFilesDictionary) {
                tmpFilesDictionary = [NSMutableDictionary dictionary];
                [restDictionary setObject:tmpFilesDictionary forKey:baseDirectoryName];
            }
            [tmpFilesDictionary setObject:hash forKey:restFileName];
        }
    }
    
    for (NSString *baseDirectoryName in [restDictionary allKeys]) {
        NSDictionary *filesDictionary = [restDictionary objectForKey:baseDirectoryName];
        
        NSString *name = nil;
        
        if ([_name isEqualToString:@""]) {
            name = baseDirectoryName;
        } else {
            name = [NSString stringWithFormat:@"%@/%@", _name, baseDirectoryName];
        }
        
        GHDirectory *newDirectory = [[[GHDirectory alloc] initWithFilesDictionary:filesDictionary name:name] autorelease];
        
        [myDirectoriesArray addObject:newDirectory];
    }
    
    *files = myFilesArray;
    *directories = myDirectoriesArray;
}

@end
