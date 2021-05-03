//
//  ViewController.swift
//  SwipeSideMenu
//
//  Created by Nishant Taneja on 03/05/21.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    
    private var sideMenu: SideMenuController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenu = SideMenuController()
        sideMenu.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !sideMenu.isHidden { sideMenu.hide() }
    }
    
    @IBAction func sideMenuButtonAction(_ sender: UIBarButtonItem) {
        sideMenu.isHidden ? sideMenu.show(from: .left) : sideMenu.hide()
    }
    
}

extension ViewController: SideMenuControllerDelegate {
    func sideMenu(controller: SideMenuController, willUpdateViewOriginTo newOrigin: CGPoint, animator: UIViewPropertyAnimator) {
        print(#function)
        animator.addAnimations {
            self.navigationController?.view.frame.origin.x = controller.edgeX
        }
    }
    
    func sideMenu(controller: SideMenuController, willDisplayFrom location: SideMenuController.SideMenuLocation, animator: UIViewPropertyAnimator) {
        print(#function)
        animator.addAnimations {
            self.navigationController?.view.frame.origin.x = controller.edgeX
        }
    }
    
    func sideMenuControllerDidDisplay(_ controller: SideMenuController) {
        print(#function)
    }
    
    func sideMenuControllerWillHide(_ controller: SideMenuController, animator: UIViewPropertyAnimator) {
        print(#function)
        animator.addAnimations {
            self.navigationController?.view.frame.origin.x = controller.edgeX
        }
    }
    
    func sideMenuControllerDidHide(_ controller: SideMenuController) {
        print(#function)
    }
    
    func sideMenu(controller: SideMenuController, didSelectProject id: Int) {
        print(#function)
    }
    
    func sideMenuControllerDidSelectSomething(_ controller: SideMenuController) {
        print(#function)
    }
}
