//
//  DrawerViewController.swift
//  NavigationDrawerDemo
//
//  Created by Chenguang Zhou on 28/6/17.
//  Copyright © 2017 Chenguang Zhou. All rights reserved.
//

import UIKit

class DrawerViewController: UIViewController, NavigationDrawerDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.gray
    }

    func widthOfDrawer() -> CGFloat {
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            return min(375.0, UIScreen.main.bounds.size.width * 0.28)
            
        } else if UI_USER_INTERFACE_IDIOM() == .phone{
            return min(375.0, UIScreen.main.bounds.size.width - 60.0)
            
        }
        
        return 300.0
    }
    
    func emergeFromLeft() -> Bool {
        return true
    }
    
    func shouldMoveCenterView() -> Bool {
        return true
    }
    
    
    func animate(withScale scale: CGFloat) {
        
    }

}
