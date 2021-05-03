//
//  SideMenuController.swift
//  SwipeSideMenu
//
//  Created by Nishant Taneja on 03/05/21.
//

import UIKit

protocol SideMenuControllerDelegate: AnyObject {
    func sideMenu(controller: SideMenuController, willUpdateViewOriginTo newOrigin: CGPoint, animator: UIViewPropertyAnimator)
    // Hide/Show
    func sideMenu(controller: SideMenuController, willDisplayFrom location: SideMenuController.SideMenuLocation, animator: UIViewPropertyAnimator)
    func sideMenuControllerDidDisplay(_ controller: SideMenuController)
    func sideMenuControllerWillHide(_ controller: SideMenuController, animator: UIViewPropertyAnimator)
    func sideMenuControllerDidHide(_ controller: SideMenuController)
    // Selection
    func sideMenu(controller: SideMenuController, didSelectProject id: Int)
    func sideMenuControllerDidSelectSomething(_ controller: SideMenuController) // Temporary
}

final class SideMenuController: UIViewController {
    lazy private var projectsCollectionView: UICollectionView = {
        self.collectionView(for: .projects)
    }()
    lazy private var settingsCollectionView: UICollectionView = {
        self.collectionView(for: .settings)
    }()
    
    var edgeX: CGFloat {
        view.frame.origin.x + view.frame.width
    }
    
    weak var delegate: SideMenuControllerDelegate?
    
    var projectID: Int?
    private var indexPathHighlighted: IndexPath?
    var isHidden: Bool = true
    private var originWhenHidden: CGPoint!
    private var side: SideMenuLocation = .left
    
    required init() {
        super.init(nibName: nil, bundle: nil)
        let mainScreenBounds = UIScreen.main.bounds
        view.frame.size = CGSize(width: 0.75*mainScreenBounds.width, height: mainScreenBounds.height)
        view.frame.origin = CGPoint(x: -view.frame.width, y: 0)
        view.backgroundColor = .green
        originWhenHidden = CGPoint(x: -view.frame.width, y: 0)
        updateViewConstraints()
        configureGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        let safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
        projectsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        settingsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(safeAreaInsets.top)-[v0]-8-[v1(244)]-\(safeAreaInsets.bottom)-|", options: .alignAllLeft, metrics: nil, views: ["v0" : projectsCollectionView, "v1" : settingsCollectionView]) + NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: .alignAllCenterX, metrics: nil, views: ["v0" : projectsCollectionView]) + NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: .alignAllCenterX, metrics: nil, views: ["v0" : settingsCollectionView])
        view.addConstraints(constraints)
    }
}

//MARK:- CollectionView
fileprivate let cellIdentifier = "CellID"
extension SideMenuController {
    private enum CollectionViewContentType { case projects, settings }
    
    private func collectionView(for contentType: CollectionViewContentType) -> UICollectionView {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        switch contentType {
        case .projects:
            collectionView.tag = 0
            collectionView.isScrollEnabled = true
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        case .settings:
            collectionView.tag = 1
            collectionView.isScrollEnabled = false
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        }
        collectionView.backgroundColor = .clear
        collectionView.register(UICollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        return collectionView
    }
}

//MARK:- Show/Hide
extension SideMenuController {
    enum SideMenuLocation { case left, right }
    
    func show(from location: SideMenuLocation) {
        side = location
        originWhenHidden = location == .left ? view.frame.origin : CGPoint(x: UIScreen.main.bounds.width + view.frame.width, y: 0)
        let animator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut) {
            self.view.frame.origin = location == .left ? CGPoint(x: 0, y: 0) : CGPoint(x: UIScreen.main.bounds.width - self.view.frame.width, y: 0)
            self.tabBarController?.view.alpha = 0.1

        }
        animator.addCompletion { _ in
            self.isHidden = false
            self.delegate?.sideMenuControllerDidDisplay(self)
        }
        delegate?.sideMenu(controller: self, willDisplayFrom: location, animator: animator)
        UIApplication.shared.windows.first?.addSubview(view)
        projectsCollectionView.reloadData()
        settingsCollectionView.reloadData()
        view.frame.origin = originWhenHidden
        animator.startAnimation()
    }
    
    func hide() {
        let animator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut) {
            self.view.frame.origin.x = -self.view.frame.width
        }
        animator.addCompletion { _ in
            self.view.removeFromSuperview()
            self.isHidden = true
            self.delegate?.sideMenuControllerDidHide(self)
        }
        delegate?.sideMenuControllerWillHide(self, animator: animator)
        animator.startAnimation()
    }
}

//MARK:- UICollectionView
extension SideMenuController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 { return 20 }
        if collectionView.tag == 1 { return 4 }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = .blue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return .init()
        }
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: cellIdentifier, for: indexPath)
        header.backgroundColor = .red
        return header
    }
    
    // DelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.visibleSize.width - 32, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 48)
    }
    
    //Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.sideMenuControllerDidSelectSomething(self)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

//MARK:- GestureRecognizers
extension SideMenuController: UIGestureRecognizerDelegate {
    private func configureGestureRecognizers() {
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(gestureRecognizer:)))
        panGR.delegate = self
        view.addGestureRecognizer(panGR)
    }
    
    @objc
    private func handleSwipe(gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self.view)
        switch gestureRecognizer.state {
        case .changed:
            guard translation.x <= 0 else { return }
            updateViewOrigin(to: CGPoint(x: translation.x, y: view.frame.origin.y))
        case .ended:
            if abs(translation.x) < self.view.frame.width/3 {
                show(from: .left)
            } else {
                hide()
            }
        default: break
        }
    }
    
    private func updateViewOrigin(to newOrigin: CGPoint) {
        let animator = UIViewPropertyAnimator(duration: 0, curve: .easeInOut) {
            self.view.frame.origin = newOrigin
        }
        delegate?.sideMenu(controller: self, willUpdateViewOriginTo: newOrigin, animator: animator)
        animator.startAnimation()
    }
}
