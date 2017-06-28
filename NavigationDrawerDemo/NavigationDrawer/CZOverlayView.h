//
//  CZOverlayView.h
//
//
//  Created by Chenguang Zhou on 21/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CZOverlayViewDelegate <NSObject>

@required
-(void)dismissOverlayView:(UIView*)view;

@end

@interface CZOverlayView : UIView {
    __weak id<CZOverlayViewDelegate> delegate;
    UIView* blurView;
}
@property (nonatomic,weak) id<CZOverlayViewDelegate> delegate;

-(void)showOverlay:(CGFloat)duration;
-(void)hideOverlay:(CGFloat)duration;

@end
