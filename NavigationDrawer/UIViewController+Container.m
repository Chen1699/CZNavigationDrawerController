//
//  UIViewController+Container.m
//   
//
//  Created by Chenguang Zhou on 10/02/14.
//
//

#import "UIViewController+Container.h"

@implementation UIViewController (Container)

- (void)containerAddChildViewController:(UIViewController *)childViewController {
    
    [self addChildViewController:childViewController];
    [self.view addSubview:childViewController.view];
    [childViewController didMoveToParentViewController:self];
    
}

- (void)containerRemoveChildViewController:(UIViewController *)childViewController {
    
    [childViewController willMoveToParentViewController:nil];
    [childViewController.view removeFromSuperview];
    [childViewController removeFromParentViewController];
    
}

@end
