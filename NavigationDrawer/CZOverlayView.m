//
//  CZOverlayView.m
//
//
//  Created by Chenguang Zhou on 21/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CZOverlayView.h"

@implementation CZOverlayView
@synthesize delegate;


-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [delegate dismissOverlayView:self];
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];

    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    blurView.frame = self.bounds;
}

-(void)showOverlay:(CGFloat)duration{
    if (blurView.superview) {
        [blurView removeFromSuperview];
    }
    blurView.frame = self.bounds;
    [self addSubview:blurView];
    
    blurView.alpha = 0.0;
    [UIView animateWithDuration:duration animations:^{
        blurView.alpha = 0.3;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hideOverlay:(CGFloat)duration{
    
    [UIView animateWithDuration:duration animations:^{
        blurView.alpha = 0.1;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
