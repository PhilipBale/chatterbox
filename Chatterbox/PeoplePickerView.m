//
//  PeoplePickerView.m
//  Chatterbox
//
//  Created by Philip Bale on 12/25/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import "PeoplePickerView.h"

@implementation PeoplePickerView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)mouseDown:(NSEvent *)theEvent
{
    
}

- (NSView *)hitTest:(NSPoint)aPoint
{
    if (self.delegate) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate peoplePickerViewClicked];
        });
    }
    return [super hitTest:aPoint];
}

@end
