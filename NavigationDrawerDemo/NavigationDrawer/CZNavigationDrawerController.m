//
//  CZNavigationDrawerController.m
//
//
//  Created by Chenguang Zhou on 20/03/14.
//
/*
 Description:
 This class implemented the layout and animation of a navigation drawer.
 
 You can implement NavigationDrawerDataSource protocol to configure the drawer's width, position & style etc.
 then use setViewControllers: to pass in the drawer viewcontroller and main viewcontroller
 
 */

#import "CZNavigationDrawerController.h"
#import "UIViewController+Container.h"

@interface CZNavigationDrawerController ()

@end

NSString* const togglerImageName = @"menu";
CGFloat const defaultDuration = 0.3;
CGFloat const defaultDrawerWidth = 220;


@implementation CZNavigationDrawerController

@synthesize dataSource;
@synthesize delegate;
@synthesize drawerViewController;
@synthesize centerViewController;

- (id)init
{
    
    self = [super init];
    
    if (self) {
        
        // Custom initialization
        
        isOpen = NO;
        _shouldShowOverlay = YES;
        
    }
    
    return self;
    
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    
    centerViewController.view.frame = self.view.bounds;
    overlayView = [[CZOverlayView alloc] initWithFrame:self.view.bounds];
    overlayView.delegate = self;
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [self addEdgePanner];
}

- (void)dealloc{
    [self removeEdgePanner];
}



-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    overlayView.frame = CGRectMake(0, 0, size.width , size.height);
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (overlayView.superview) {
            overlayView.frame = CGRectMake(0, 0, centerViewController.view.bounds.size.width , centerViewController.view.bounds.size.height);
        }
        
        if (dataSource) {
            drawerWidth = [dataSource widthOfDrawer];
            [self updateFrame];
        }
    }];
    
}


-(void)setViewControllers:(NSArray *)viewControllers_{
    
    if ([viewControllers_ count] >= 2) {
        
        if (dataSource) {
            
            drawerWidth = [dataSource widthOfDrawer];
            emergeFromLeft = [dataSource emergeFromLeft];
            shouldMoveCenterView = [dataSource shouldMoveCenterView];
        } else {
            
            drawerWidth = defaultDrawerWidth;
            emergeFromLeft = YES;
            shouldMoveCenterView = YES;
        }
        
        self.drawerViewController = [viewControllers_ objectAtIndex:0];
        
        self.centerViewController = [viewControllers_ objectAtIndex:1];
        
        if(!shouldMoveCenterView){
            [self.view insertSubview:self.drawerViewController.view aboveSubview:self.centerViewController.view];
        } else {
            [self.view insertSubview:self.drawerViewController.view belowSubview:self.centerViewController.view];
        }
        
    }
    
}



-(void)setDrawerViewController:(UIViewController *)drawerViewController_{
    
    if (drawerViewController) {
        
        [self containerRemoveChildViewController:drawerViewController];
        
    }
    
    drawerViewController = drawerViewController_;
    
    [self containerAddChildViewController:drawerViewController];
    
    
    drawerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [self updateFrame];
}

-(void)setCenterViewController:(UIViewController *)centerViewController_{
    
    if (centerViewController) {
        [self containerRemoveChildViewController:centerViewController];
        
    }
    
    centerViewController = centerViewController_;
    
    centerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [self containerAddChildViewController:centerViewController];
    
    [self updateFrame];
    
    if(!shouldMoveCenterView){
        [self.view sendSubviewToBack:self.centerViewController.view];
    } else {
        [self.view sendSubviewToBack:self.drawerViewController.view];
    }
    
    [self applyShadowToView:centerViewController.view];
    
    
    UIViewController* vc = nil;
    @try {
        
        if ([centerViewController isKindOfClass:[UITabBarController class]]) {
            for (UINavigationController* navC in ((UITabBarController*)centerViewController).viewControllers) {
                if ([navC isKindOfClass:[UINavigationController class]]) {
                    vc = navC.topViewController;
                    
                }
            }
            
        } else if ([centerViewController isKindOfClass:[UINavigationController class]]) {
            
            vc = ((UINavigationController*)centerViewController).topViewController;
            
        } else {
            
            vc = nil;
            
        }
        
    }
    
    @catch (NSException *exception) {
        
    }
    
    
    if (vc) {
        UIBarButtonItem* toggleBarItem = [self getToggleBarButton];
        if (emergeFromLeft) {
            
            vc.navigationItem.leftBarButtonItem = toggleBarItem;
            
        } else {
            
            vc.navigationItem.rightBarButtonItem = toggleBarItem;
            
        }
        
    } else {
        UIButton* toggleButton = [self getToggleButton];
        if ([centerViewController conformsToProtocol:@protocol(CenterControllerDelegate) ]){
            [(UIViewController<CenterControllerDelegate>*)centerViewController configureToggleButton:toggleButton];
        }
    }
    
}

-(UIBarButtonItem*)getToggleBarButton{
    
    UIButton* menuButton = [self getToggleButton];
    UIBarButtonItem* toggleBarItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton ];
    return toggleBarItem;
    
}

-(UIButton*)getToggleButton{
    
    UIButton* menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 32)];
    [menuButton setImage:[UIImage imageNamed:togglerImageName] forState:UIControlStateNormal];
    
    
    [menuButton addTarget:self action:@selector(openDrawer) forControlEvents:UIControlEventTouchUpInside];
    
    return menuButton;
    
}


-(void)openDrawer{
    
    [self toggleDrawer:YES];
    
}

-(void)closeDrawer{
    
    [self toggleDrawer:NO];
    
}

-(void)toggleDrawer:(BOOL)open {
    
    [self toggleDrawer:open duration:defaultDuration];
    
}

-(void)toggleDrawer:(BOOL)open duration:(CGFloat) duration{
    
    isOpen = open;
    
    if (open) {
        
        if (self.shouldShowOverlay) {
            overlayView.frame = CGRectMake(0, 0, centerViewController.view.frame.size.width , centerViewController.view.frame.size.height);
            [centerViewController.view addSubview:overlayView];
            [overlayView showOverlay:duration+0.2];
        }
        
        [UIView animateWithDuration:duration
         
                         animations:^{
                             [self updateFrame];
                             
                         }completion:^(BOOL finished){
                             
                             if(delegate){
                                 [delegate didToggleDrawer:open];
                             }
                         }];
        
        [self addPanner];
        
    }else{
        
        CGFloat delay = 0.0;
        if(delegate){
            delay = [delegate didToggleDrawer:open];
        }
        
        if (self.shouldShowOverlay) {
            if (overlayView.superview != centerViewController.view) {
                [centerViewController.view addSubview:overlayView];
            }
            
            [overlayView hideOverlay:duration + delay];
        }
        
        
        [UIView animateWithDuration:duration
                              delay:delay
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self updateFrame];
                         } completion:^(BOOL finished) {
                             
                         }];
        
        [self removePanner];
        
    }
    
}

-(void)updateFrame{
    
    CGFloat originX = shouldMoveCenterView ? ( isOpen ? (emergeFromLeft ? drawerWidth : -drawerWidth) : 0) : 0;
    centerViewController.view.frame = CGRectMake(originX, 0, self.view.frame.size.width , self.view.frame.size.height);
    
    CGFloat originX_drawer = shouldMoveCenterView ? (emergeFromLeft ? 0 : self.view.frame.size.width - drawerWidth) : ( isOpen ?  (emergeFromLeft ? 0 : self.view.frame.size.width - drawerWidth) : (emergeFromLeft ? -drawerWidth : self.view.frame.size.width)) ;
    
    drawerViewController.view.frame = CGRectMake(originX_drawer, 0, drawerWidth , self.view.frame.size.height);

}


//MARK: Overlay delegate

-(void)dismissOverlayView:(CZOverlayView*)olView{
    
    [self toggleDrawer:NO];
    
}

- (void)addPanner {
    
    UIView* view = centerViewController.view;
    if (!shouldMoveCenterView) {
        view = drawerViewController.view;
    }
    
    if (!view) return;
    
    if (!myPanner) {
        
        myPanner = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
        myPanner.cancelsTouchesInView = YES;
        myPanner.delegate = self;
    }
    
    [view addGestureRecognizer:myPanner];
    
}

-(void)removePanner{
    
    UIView* view = centerViewController.view;
    if (!shouldMoveCenterView) {
        view = drawerViewController.view;
    }
    
    if (myPanner) {
        [view removeGestureRecognizer:myPanner];
    }
    
}

-(void)addEdgePanner{
    if (!edgeGesture) {
        edgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
        if (emergeFromLeft) {
            edgeGesture.edges = UIRectEdgeLeft;
        } else {
            edgeGesture.edges = UIRectEdgeRight;
        }
    }
    
    [self.view addGestureRecognizer:edgeGesture];
}

-(void)removeEdgePanner{
    if (edgeGesture) {
        [self.view removeGestureRecognizer:edgeGesture];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    return NO;
    
}

- (void)panned:(UIPanGestureRecognizer*)panner {
    
    UIView *piece = [panner view];
    
    
    static CGPoint oldTranslation ;
    
    static CZSwipeGestureDirection direction = CZSwipeGestureDirectionNone;
    
    
    CGPoint translation = [panner translationInView:piece.superview];
    
    if ((fabs(translation.y ) > fabs(translation.x) ) && direction == CZSwipeGestureDirectionNone) {
        
        //gesture starts with vertical panning, should be ignored
        
        return;
        
    }
    
    
    if (translation.x - oldTranslation.x > 0) {
        
        direction = CZSwipeGestureDirectionRight;
        
    } else if (translation.x - oldTranslation.x < 0){
        
        direction = CZSwipeGestureDirectionLeft;
        
    }
    
    CGFloat maximumSlide = drawerWidth;
    
    if (translation.x >= maximumSlide ) {
        
        translation = CGPointMake(maximumSlide, translation.y);
        
    } else if (translation.x <= -maximumSlide){
        
        translation = CGPointMake(-maximumSlide, translation.y);
        
    }
    
    
    CGPoint translationDelta = CGPointMake(translation.x - oldTranslation.x, translation.y - oldTranslation.y);
    
    oldTranslation = translation;
    
    
    CGPoint velocity = [panner velocityInView:[piece superview]];
    
    
    
    UIView* targetView = centerViewController.view;
    if (!shouldMoveCenterView) {
        targetView = drawerViewController.view;
    }
    
    
    if (panner.state == UIGestureRecognizerStateBegan || panner.state == UIGestureRecognizerStateChanged) {
        
        
        CGRect frame = targetView.frame;
        
        frame.origin.x = frame.origin.x  + translationDelta.x;
        
        if (shouldMoveCenterView) {
            frame.origin.x = emergeFromLeft ? MAX(0, MIN(frame.origin.x, maximumSlide)) : MIN(0, MAX(frame.origin.x, -maximumSlide));
        } else {
            frame.origin.x = emergeFromLeft ? MIN(0, MAX(frame.origin.x, -maximumSlide)) : MAX(self.view.frame.size.width - maximumSlide, MIN(frame.origin.x, maximumSlide));
        }
        
        [targetView setFrame:frame];
        
        
    } else if (panner.state == UIGestureRecognizerStateEnded || panner.state == UIGestureRecognizerStateCancelled || panner.state == UIGestureRecognizerStateFailed){
        
        
        CGFloat duration = defaultDuration;
        
        if (velocity.x != 0) {
            
            duration = MAX( MIN( (drawerWidth - fabs(translation.x))/ fabs(velocity.x), 0.5), 0.1);
            
        }
        
        
        CGFloat backDuration = defaultDuration;
        
        if (velocity.x != 0) {
            
            backDuration = MAX( MIN( (fabs(translation.x))/ fabs(velocity.x), 0.5), 0.1);
            
        }
        
        
        if (ABS(velocity.x) > 300) {//this is a swipe
            
            if (piece == targetView) {
                
                if ([self isSwipeClosingDrawer:direction]) {//swipe direction is the same as menu-close direction
                    
                    [self toggleDrawer:NO duration:backDuration];// close drawer
                    
                } else {
                    
                    [self toggleDrawer:YES duration:duration]; // open drawer
                    
                }
                
            } else {
                
                if ([self isSwipeClosingDrawer:direction]) {//swipe direction is the same as menu-close direction
                    
                    [self toggleDrawer:NO duration:duration];// close drawer
                    
                } else {
                    
                    [self toggleDrawer:YES duration:backDuration]; // open drawer
                    
                }
                
            }
            
        } else {
            
            //it's tricky to guess user's intention
            //I originally want to do "keep going ahead if passes the middle line" by adding ABS(translation.x) >= drawerWidth/2 && [self isSwipeClosingDrawer:direction]
            //however, if drawer is already open, a small pan will close the drawer, which is not ideal
            
            
            if (ABS(translation.x) >= drawerWidth/2) {
                //keep going ahead if passes the middle line, i.e. toggle drawer state
                
                [self toggleDrawer:!isOpen duration:duration];
                
            } else {
                
                [self toggleDrawer:isOpen duration:backDuration];
                
            }
            
            
        }
        
        oldTranslation = CGPointZero;
        
        direction = CZSwipeGestureDirectionNone;
        
    }
    
}


//MARK - Helper methods

-(BOOL) isSwipeClosingDrawer:(CZSwipeGestureDirection) direction{
    
    if ((emergeFromLeft && direction == CZSwipeGestureDirectionLeft) || (!emergeFromLeft && direction == CZSwipeGestureDirectionRight)){
        
        return YES;
        
    } else {
        
        return NO;
        
    }
    
}

-(CGFloat)drawerWidth{
    return drawerWidth;
}

-(void)applyShadowToView:(UIView*)theView{
    @try {
        UIBezierPath* newShadowPath = [UIBezierPath bezierPathWithRect:theView.bounds];
        theView.layer.masksToBounds = NO;
        theView.layer.shadowRadius = 3.0;// theView.layer.cornerRadius; //The blur radius (in points) used to render the layer’s shadow. Animatable.
        theView.layer.shadowOpacity = 1.0;
        UIColor* color = [UIColor blackColor];
        theView.layer.shadowColor = [color CGColor];
        theView.layer.shadowOffset = CGSizeZero;
        theView.layer.shadowPath = [newShadowPath CGPath];
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}


@end
