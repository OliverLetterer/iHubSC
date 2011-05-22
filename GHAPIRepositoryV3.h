//
//  GHAPIRepositoryV3.h
//  iGithub
//
//  Created by Oliver Letterer on 22.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHAPIRepositoryV3 : NSObject {
@private
    
}

+ (void)labelOnRepository:(NSString *)repository completionHandler:(void(^)(NSArray *labels, NSError *error))handler;

@end
