//
//  GHPDiffView.m
//  iGithub
//
//  Created by Oliver Letterer on 03.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPDiffView.h"
#import "NSString+Additions.h"

UIFont *GHPDiffViewFont(void) {
    return [UIFont fontWithName:@"CourierNewPSMT" size:14.0f];
}

UIFont *GHPDiffViewBoldFont(void) {
    return [UIFont fontWithName:@"CourierNewPS-BoldMT" size:14.0f];
}

@implementation GHPDiffView

@synthesize diffString=_diffString, lineNumbersView=_lineNumbersView, contentDiffView=_contentDiffView, scrollView=_scrollView;
@synthesize borderColor=_borderColor;

#pragma mark - setters and getters

- (void)setDiffString:(NSString *)diffString {
    [_diffString release];
    NSMutableString *tmpString = [[diffString mutableCopy] autorelease];
    NSRange deleteRange = [tmpString rangeOfString:@"@@ -" options:NSCaseInsensitiveSearch];
    if (deleteRange.location != NSNotFound) {
        [tmpString deleteCharactersInRange:NSMakeRange(0, deleteRange.location)];
    }
    [tmpString appendString:@"\n"];
    _diffString = [[NSString alloc] initWithString:tmpString];
    
    __block BOOL firstInfoLine = YES;
    NSMutableString *oldLinesString = [NSMutableString string];
    NSMutableString *newLinesString = [NSMutableString string];
    
    __block NSInteger currentOldLine = 0;
    __block NSInteger currentNewLine = 0;
    
    [_diffString enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        if ([line hasPrefix:@"@@"]) {
            // this is a "@@ -73,10 +77,12 @@ XXXXXXXXXXX" line
            // -73,10 == old lines start with 73 and contain 10 lines
            // +77,12 == new lines start with 77 and contain 12 lines
            
            if (firstInfoLine) {
                firstInfoLine = NO;
            } else {
                [oldLinesString appendString:@"...\n"];
                [newLinesString appendString:@"...\n"];
            }
            NSString *currentOldLineString = [line stringBetweenString:@"-" andString:@","];
            NSString *currentNewLineString = [line stringBetweenString:@"+" andString:@","];
            
            currentOldLine = [currentOldLineString intValue];
            currentNewLine = [currentNewLineString intValue];
        } else if ([line hasPrefix:@"+"]) {
            // a line that has been added
            [oldLinesString appendString:@"\n"];
            [newLinesString appendFormat:@"%d\n", currentNewLine];
            currentNewLine++;
        } else if ([line hasPrefix:@"-"]) {
            // a line that has been removed
            [oldLinesString appendFormat:@"%d\n", currentOldLine];
            [newLinesString appendString:@"\n"];
            currentOldLine++;
        } else {
            [oldLinesString appendFormat:@"%d\n", currentOldLine];
            [newLinesString appendFormat:@"%d\n", currentNewLine];
            currentOldLine++;
            currentNewLine++;
        }
    }];
    
    [self.lineNumbersView setOldLines:oldLinesString newLines:newLinesString];
    self.contentDiffView.diffString = _diffString;
    
    [self setNeedsLayout];
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        self.borderColor = [UIColor colorWithRed:191.0f/255.0f green:191.0f/255.0f blue:191.0f/255.0f alpha:1.0f];
        self.lineNumbersView = [[[GHPDiffViewLineNumbersView alloc] initWithFrame:CGRectZero] autorelease];
        [self addSubview:self.lineNumbersView];
        self.backgroundColor = [UIColor whiteColor];
        
        self.contentDiffView = [[[GHPDiffViewContentView alloc] initWithFrame:CGRectZero] autorelease];
        self.scrollView = [[[UIScrollView alloc] initWithFrame:CGRectZero] autorelease];
        self.scrollView.scrollsToTop = NO;
        [self.scrollView addSubview:self.contentDiffView];
        [self addSubview:self.scrollView];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self.borderColor setStroke];
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRect:CGRectMake(0.5f, 0.5f, CGRectGetWidth(rect)-1.0f, CGRectGetHeight(rect)-1.0f)];
    [borderPath setLineWidth:1.0f];
    [borderPath stroke];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat linesWidth = self.lineNumbersView.width;
    self.lineNumbersView.frame = CGRectMake(0.0f, 0.0f, linesWidth, CGRectGetHeight(self.bounds));
    self.scrollView.frame = CGRectMake(linesWidth, 0.0f, CGRectGetWidth(self.bounds)-linesWidth-1.0f, CGRectGetHeight(self.bounds));
    CGFloat contentDiffViewWidth = self.contentDiffView.width;
    if (contentDiffViewWidth < CGRectGetWidth(self.scrollView.bounds)) {
        contentDiffViewWidth = CGRectGetWidth(self.scrollView.bounds);
    }
    self.contentDiffView.frame = CGRectMake(0.0f, 0.0f, contentDiffViewWidth, CGRectGetHeight(self.bounds));
    self.scrollView.contentSize = self.contentDiffView.frame.size;
}

#pragma mark - Memory management

- (void)dealloc {
    [_diffString release];
    [_lineNumbersView release];
    [_borderColor release];
    [_contentDiffView release];
    [_scrollView release];
    
    [super dealloc];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_borderColor forKey:@"borderColor"];
    [encoder encodeObject:_diffString forKey:@"diffString"];
    [encoder encodeObject:_lineNumbersView forKey:@"lineNumbersView"];
    [encoder encodeObject:_contentDiffView forKey:@"contentDiffView"];
    [encoder encodeObject:_scrollView forKey:@"scrollView"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _borderColor = [[decoder decodeObjectForKey:@"borderColor"] retain];
        _diffString = [[decoder decodeObjectForKey:@"diffString"] retain];
        _lineNumbersView = [[decoder decodeObjectForKey:@"lineNumbersView"] retain];
        _contentDiffView = [[decoder decodeObjectForKey:@"contentDiffView"] retain];
        _scrollView = [[decoder decodeObjectForKey:@"scrollView"] retain];
    }
    return self;
}

@end
