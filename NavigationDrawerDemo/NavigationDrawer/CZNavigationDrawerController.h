//
//  CZNavigationDrawerController.h
//
//  Created by Chenguang Zhou on 20/03/14.
//
//

#import "CZOverlayView.h"


@class CZNavigationDrawerController;

typedef NS_ENUM(NSInteger, CZSwipeGestureDirection) {
    CZSwipeGestureDirectionNone,
    CZSwipeGestureDirectionLeft,
    CZSwipeGestureDirectionRight,
    CZSwipeGestureDirectionUp,
    CZSwipeGestureDirectionDown,
    
};



@protocol NavigationDrawerDataSource <NSObject>
@required

-(CGFloat) widthOfDrawer;
-(BOOL) emergeFromLeft;
-(void) animateWithScale:(CGFloat)scale;
-(BOOL) shouldMoveCenterView;

@end

@protocol NavigationDrawerDelegate <NSObject>

@required
-(CGFloat) didToggleDrawer:(BOOL)open;

@end

@protocol CenterControllerDelegate <NSObject>

@required
-(void) configureToggleButton:(UIButton*)button;

@end

@interface CZNavigationDrawerController : UIViewController<UIGestureRecognizerDelegate, CZOverlayViewDelegate>{
    __weak id<NavigationDrawerDataSource> dataSource;
    __weak id<NavigationDrawerDelegate> delegate;
    
    UIViewController* drawerViewController;
    UIViewController* centerViewController;
    
    CGFloat drawerWidth;
    BOOL shouldMoveCenterView;
    BOOL emergeFromLeft;
    
    BOOL isOpen;
    
    CZOverlayView* overlayView;
    
    UIPanGestureRecognizer* myPanner;
    UIScreenEdgePanGestureRecognizer* edgeGesture;
    
}
@property(nonatomic, weak) id<NavigationDrawerDataSource> dataSource;
@property(nonatomic, weak) id<NavigationDrawerDelegate> delegate;

@property(nonatomic, strong) UIViewController* drawerViewController;
@property(nonatomic, strong) UIViewController* centerViewController;
@property(nonatomic, assign) BOOL shouldShowOverlay;

-(void)setViewControllers:(NSArray *)viewControllers_;
-(CGFloat)drawerWidth;
-(void)openDrawer;
-(void)closeDrawer;
@end
