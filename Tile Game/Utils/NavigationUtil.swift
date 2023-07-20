//
//  NavigationUtil.swift
//  Tile Game
//
//  Created by Jack Allie on 11/1/2023.
//

import Foundation

import UIKit

// Code snippet taken from https://rekerrsive.medium.com/three-ways-to-pop-to-the-root-view-in-a-swiftui-navigationview-430aee720c9a
//struct NavigationUtil {
//    static func popToRootView() {
//        findNavigationController(viewController: UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController)?
//            .popToRootViewController(animated: true)
//    }
//
//    static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
//        guard let viewController = viewController else {
//            return nil
//        }
//        if let navigationController = viewController as? UINavigationController {
//            return navigationController
//        }
//        for childViewController in viewController.children {
//            return findNavigationController(viewController: childViewController)
//        }
//        return nil
//    }
//}
