//
//  GHTextView.m
//  iGithub
//
//  Created by Oliver Letterer on 19.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHTextView.h"


@implementation GHTextView

@synthesize text=_text, attributedString=_attributedString, delegate=_delegate;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame text:(NSString *)text delegate:(id<GHTextViewDelegate>)delegate {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        self.text = text;
        self.attributedString = [[[NSMutableAttributedString alloc] init] autorelease];
        self.backgroundColor = [UIColor clearColor];
        self.delegate = delegate;
        
        dispatch_queue_t tmpQueue = dispatch_queue_create("de.olettere.tmpQueue001", NULL);
        dispatch_async(tmpQueue, ^(void) {
            if ([self.text length] > 10000) {
                self.attributedString = [[[NSMutableAttributedString alloc] initWithString:self.text] autorelease];
            } else {
                [self.text enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                    NSAttributedString *attributesString = [self.delegate textView:self formattedLineFromText:line];
                    [self.attributedString appendAttributedString:attributesString ];
                    
                    [self.attributedString appendAttributedString:[[[NSAttributedString alloc] initWithString:@"\n"] autorelease] ];
                }];
            }
            
            CTFontRef myFont = CTFontCreateWithName((CFStringRef)@"Courier", 16.0, NULL);
            
            [self.attributedString addAttribute:(NSString *)kCTFontAttributeName 
                                          value:(id)myFont 
                                          range:NSMakeRange(0, [self.attributedString length])];
            
            CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFMutableAttributedStringRef)self.attributedString);
            _suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, 0), NULL, CGSizeZero, NULL);
            
            _suggestedSize.width = ceilf(_suggestedSize.width);
            _suggestedSize.height = ceilf(_suggestedSize.height);
            
            CFRelease(myFont);
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                _frameSetter = frameSetter;
                [self.delegate textViewDidParseText:self];
                [self setNeedsDisplay];
                dispatch_release(tmpQueue);
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
    [_text release];
    [_attributedString release];
    if (_frameSetter) {
        CFRelease(_frameSetter);
    }
    [super dealloc];
}

@end
