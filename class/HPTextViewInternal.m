//
//  HPTextViewInternal.m
//
//  Created by Hans Pinckaers on 29-06-10.
//
//	MIT License
//
//	Copyright (c) 2011 Hans Pinckaers
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

#import "HPTextViewInternal.h"


@implementation HPTextViewInternal

-(void)setText:(NSString *)text
{
    BOOL originalValue = self.scrollEnabled;
    //If one of GrowingTextView's superviews is a scrollView, and self.scrollEnabled == NO,
    //setting the text programatically will cause UIKit to search upwards until it finds a scrollView with scrollEnabled==yes
    //then scroll it erratically. Setting scrollEnabled temporarily to YES prevents this.
    [self setScrollEnabled:YES];
    [super setText:text];
    [self setScrollEnabled:originalValue];
}

- (void)setScrollable:(BOOL)isScrollable
{
    [super setScrollEnabled:isScrollable];
}

-(void)setContentOffset:(CGPoint)s
{
	if(self.tracking || self.decelerating){
		//initiated by user...
        
        UIEdgeInsets insets = self.contentInset;
        insets.bottom = 0;
        insets.top = 0;
        self.contentInset = insets;
        
	} else {

		float bottomOffset = (self.contentSize.height - self.frame.size.height + self.contentInset.bottom);
		if(s.y + 8 <= bottomOffset && self.scrollEnabled){
            UIEdgeInsets insets = self.contentInset;
            insets.bottom = 8;
            insets.top = 0;
            self.contentInset = insets;            
        }
	}
    
    // Fix "overscrolling" bug
    if (s.y > self.contentSize.height - self.frame.size.height && !self.decelerating && !self.tracking && !self.dragging)
    {
        s = CGPointMake(s.x, self.contentSize.height - self.frame.size.height);
    
        if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)]) {
            [self performSelector:@selector(resetOverScrollPositionForIOS7) withObject:nil afterDelay:0.1];
            return;
        }
    }

	[super setContentOffset:s];
}

-(void)resetOverScrollPositionForIOS7
{
    CGPoint s = self.contentOffset;
    if (s.y > self.contentSize.height - self.frame.size.height && !self.decelerating && !self.tracking && !self.dragging) {
        s = CGPointMake(s.x, self.contentSize.height - self.frame.size.height);
        [self setContentOffset:s animated:NO];
    }
}

-(void)setContentInset:(UIEdgeInsets)s
{
	UIEdgeInsets insets = s;
	
	if(s.bottom>8) insets.bottom = 0;
	insets.top = 0;

	[super setContentInset:insets];
}

-(void)setContentSize:(CGSize)contentSize
{
    // is this an iOS5 bug? Need testing!
    if(self.contentSize.height > contentSize.height)
    {
        UIEdgeInsets insets = self.contentInset;
        insets.bottom = 0;
        insets.top = 0;
        self.contentInset = insets;
    }
    
    [super setContentSize:contentSize];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (self.displayPlaceHolder && self.placeholder && self.placeholderColor) {
		// Inset the rect
		rect = UIEdgeInsetsInsetRect(rect, self.contentInset);
        
		// TODO: This is hacky. Not sure why 8 is the magic number
		if (self.contentInset.left == 0.0f) {
			rect.origin.x += 8.0f;
		}
		rect.origin.y += 8.0f;
        
		// Draw the text
		[self.placeholderColor set];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
		[_placeholder drawInRect:rect withFont:self.font lineBreakMode:NSLineBreakByTruncatingTail alignment:self.textAlignment];
#else
		[_placeholder drawInRect:rect withFont:self.font lineBreakMode:UILineBreakModeTailTruncation alignment:self.textAlignment];
#endif
	}
}

-(void)setPlaceholder:(NSString *)placeholder
{
	_placeholder = placeholder;
	
	[self setNeedsDisplay];
}

@end
