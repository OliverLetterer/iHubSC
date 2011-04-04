//
//  GHAuthenticationManager.h
//  iGithub
//
//  Created by Oliver Letterer on 04.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHAuthenticationManager : NSObject {
@private
    NSString *_username;
    NSString *_password;
}

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

@end


@interface GHAuthenticationManager (Singleton)

+ (GHAuthenticationManager *)sharedInstance;

@end
