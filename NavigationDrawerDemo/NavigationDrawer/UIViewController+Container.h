//
//  UIViewController+Container.h
//   
//
//  Created by Chenguang Zhou on 10/02/14.
//
//

#import <UIKit/UIKit.h>

@interface UIViewController (Container)
- (void)containerAddChildViewController:(UIViewController *)childViewController;
- (void)containerRemoveChildViewController:(UIViewController *)childViewController;
@end
