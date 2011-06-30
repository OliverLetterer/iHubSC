//
//  UIImage+GHTabBar.m
//  iGithub
//
//  Created by Oliver Letterer on 30.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "UIImage+GHTabBar.h"

@implementation UIImage (GHTabBar)

- (UIImage *)tabBarBackgroundImageWithSize:(CGSize)targetSize backgroundImage:(UIImage*)backgroundImage {
    // The background is either the passed in background image (for the blue selected state) or gray (for the non-selected state)
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    if (backgroundImage)
    {
        // Draw the background image centered
        [backgroundImage drawInRect:CGRectMake((targetSize.width - CGImageGetWidth(backgroundImage.CGImage)) / 2, (targetSize.height - CGImageGetHeight(backgroundImage.CGImage)) / 2, CGImageGetWidth(backgroundImage.CGImage), CGImageGetHeight(backgroundImage.CGImage))];
    }
    else
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        NSArray *colors = [NSArray arrayWithObjects:
                           (id)[UIColor grayColor].CGColor,
                           (id)[UIColor darkGrayColor].CGColor,
                           nil];
        CGFloat locations[] = {0.0f, 1.0f};
        CGGradientRef colorGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, locations);
        CGPoint startPoint = CGPointMake(targetSize.width/2.0f, 0.0f);
        CGPoint endPoint = startPoint;
        endPoint.y = targetSize.height;
        CGContextDrawLinearGradient(ctx, colorGradient, startPoint, endPoint,0);
        
        CGColorSpaceRelease(colorSpace);
        CGGradientRelease(colorGradient);
    }
    
    UIImage* finalBackgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalBackgroundImage;
}

// Convert the image's fill color to black and background to white
- (UIImage *)blackFilledImageWithWhiteBackgroundUsing:(UIImage*)startImage {
    // Create the proper sized rect
    CGRect imageRect = CGRectMake(0, 0, CGImageGetWidth(startImage.CGImage), CGImageGetHeight(startImage.CGImage));
    
    // Create a new bitmap context
    CGContextRef context = CGBitmapContextCreate(NULL, imageRect.size.width, imageRect.size.height, 8, 0, CGImageGetColorSpace(startImage.CGImage), kCGImageAlphaPremultipliedLast);
    
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    CGContextFillRect(context, imageRect);
    
    // Use the passed in image as a clipping mask
    CGContextClipToMask(context, imageRect, startImage.CGImage);
    // Set the fill color to black: R:0 G:0 B:0 alpha:1
    CGContextSetRGBFillColor(context, 0, 0, 0, 1);
    // Fill with black
    CGContextFillRect(context, imageRect);
    
    // Generate a new image
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage* newImage = [UIImage imageWithCGImage:newCGImage scale:startImage.scale orientation:startImage.imageOrientation];
    
    // Cleanup
    CGContextRelease(context);
    CGImageRelease(newCGImage);
    
    return newImage;
}

- (UIImage *)tabBarStyledImageWithSize:(CGSize)targetSize style:(BOOL)selected {
    UIImage *backgroundImageSource = selected ? [UIImage imageNamed:@"TabBarItemSelectedBackground.png"] : nil;
    
    UIImage *startImage = self;
    
    UIImage* backgroundImage = [self tabBarBackgroundImageWithSize:startImage.size backgroundImage:backgroundImageSource];
    
    // Convert the passed in image to a white backround image with a black fill
    UIImage* bwImage = [self blackFilledImageWithWhiteBackgroundUsing:startImage];
    
    // Create an image mask
    CGImageRef imageMask = CGImageMaskCreate(CGImageGetWidth(bwImage.CGImage),
                                             CGImageGetHeight(bwImage.CGImage),
                                             CGImageGetBitsPerComponent(bwImage.CGImage),
                                             CGImageGetBitsPerPixel(bwImage.CGImage),
                                             CGImageGetBytesPerRow(bwImage.CGImage),
                                             CGImageGetDataProvider(bwImage.CGImage), NULL, YES);
    
    // Using the mask create a new image
    CGImageRef tabBarImageRef = CGImageCreateWithMask(backgroundImage.CGImage, imageMask);
    
    UIImage* tabBarImage = [UIImage imageWithCGImage:tabBarImageRef scale:startImage.scale orientation:startImage.imageOrientation];
    
    // Cleanup
    CGImageRelease(imageMask);
    CGImageRelease(tabBarImageRef);
    
    // Create a new context with the right size
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    
    // Draw the new tab bar image at the center
    CGRect drawRect = CGRectMake((targetSize.width/2.0) - (startImage.size.width/2.0), 
                                 (targetSize.height/2.0) - (startImage.size.height/2.0), 
                                 startImage.size.width, 
                                 startImage.size.height);
    [tabBarImage drawInRect:drawRect];
    
    // Generate a new image
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

@end
