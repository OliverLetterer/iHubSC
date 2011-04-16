//
//  GHCommitDiffView.m
//  iGithub
//
//  Created by Oliver Letterer on 15.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCommitDiffView.h"
#import <dispatch/dispatch.h>

@implementation GHCommitDiffView

@synthesize diffString=_diffString, attributedString=_attributedString, delegate=_delegate;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame diffString:(NSString *)diffString delegate:(id<GHCommitDiffViewDelegate>)delegate {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        self.diffString = diffString;
        self.attributedString = [[[NSMutableAttributedString alloc] init] autorelease];
        self.backgroundColor = [UIColor clearColor];
        self.delegate = delegate;
        dispatch_queue_t tmpQueue = dispatch_queue_create("de.olettere.tmpQueue001", NULL);
        
        dispatch_async(tmpQueue, ^(void) {
            __block NSInteger loc = 0;
            [self.diffString enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                [self.attributedString appendAttributedString:[[[NSAttributedString alloc] initWithString:line] autorelease] ];
                CGColorRef textColor = [UIColor blackColor].CGColor;
                
                if ([line hasPrefix:@"---"] || [line hasPrefix:@"-"]) {
                    textColor = [UIColor redColor].CGColor;
                } else if ([line hasPrefix:@"+++"] || [line hasPrefix:@"+"]) {
                    textColor = [UIColor greenColor].CGColor;
                } else if ([line hasPrefix:@"@@"]) {
                    textColor = [UIColor grayColor].CGColor;
                }
                
                [self.attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName 
                                              value:(id)textColor 
                                              range:NSMakeRange(loc, [line length])];
                loc += [line length];
                [self.attributedString appendAttributedString:[[[NSAttributedString alloc] initWithString:@"\n"] autorelease] ];
                loc++;
            }];
            
            CTFontRef myFont = CTFontCreateWithName((CFStringRef)@"Courier", 16.0, NULL);
            
            [self.attributedString addAttribute:(NSString *)kCTFontAttributeName 
                                          value:(id)myFont 
                                          range:NSMakeRange(0, [self.attributedString length])];
            
            CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFMutableAttributedStringRef)self.attributedString);
            _suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, 0), NULL, CGSizeZero, NULL);
            
            _suggestedSize.width = ceilf(_suggestedSize.width);
            _suggestedSize.height = ceilf(_suggestedSize.height);
            
            CFRelease(myFont);
            
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                dispatch_release(tmpQueue);
                _frameSetter = frameSetter;
                [self.delegate commitDiffViewDidParseText:self];
                [self setNeedsDisplay];
            });
        });
    }
    return self;
}

- (void)sizeToFit {
    CGRect frame = self.frame;
    frame.size = _suggestedSize;
    self.frame = frame;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.backgroundColor setFill];
    CGContextFillRect(context, self.bounds);
    
    if (!_frameSetter) {
        return;
    }
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, ([self bounds]).size.height );
	CGContextScaleCTM(context, 1.0, -1.0);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    CTFrameRef frame = CTFramesetterCreateFrame(_frameSetter, CFRangeMake(0, 0), path, NULL);
    CTFrameDraw(frame, context);
    
    CFRelease(path);
    CFRelease(frame);
}

#pragma mark - Memory management

- (void)dealloc {
    [_diffString release];
    [_attributedString release];
    if (_frameSetter) {
        CFRelease(_frameSetter);
    }
    [super dealloc];
}

@end
