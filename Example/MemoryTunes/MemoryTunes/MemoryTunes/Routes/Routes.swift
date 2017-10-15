//
//  Routes.swift
//  MemoryTunes
//
//  Created by marcow on 2017/10/14.
//  Copyright © 2017年 raywenderlich. All rights reserved.
//

import ReSwiftRouter

let storyboard = UIStoryboard(name: "Main", bundle: nil)

//class RootRoutable: Routable {
//  let window: UIWindow
//
//  init(window: UIWindow) {
//    self.window = window
//  }
//
//  func setToMenuTableView() -> Routable {
//    let rootViewController =
//      storyboard.instantiateViewController(withIdentifier:
//        RouteID.menu.storyboardID)
//    let navigationController = UINavigationController(rootViewController:
//      rootViewController)
//    self.window.rootViewController = navigationController
//
//    return MainViewRoutable(self.window.rootViewController!)
//  }
//
//  func changeRouteSegment(
//    _ from: RouteElementIdentifier,
//    to: RouteElementIdentifier,
//    animated: Bool,
//    completionHandler: @escaping RoutingCompletionHandler) -> Routable {
//    completionHandler()
//    return setToMenuTableView()
//  }
//
////  func pushRouteSegment(
////    _ routeElementIdentifier: RouteElementIdentifier,
////    animated: Bool,
////    completionHandler: @escaping RoutingCompletionHandler) -> Routable {
////    completionHandler()
////    return setToMenuTableView()
////  }
//
//  func popRouteSegment(
//    _ routeElementIdentifier: RouteElementIdentifier,
//    animated: Bool,
//    completionHandler: @escaping RoutingCompletionHandler)
//  {
//    // TODO: this should technically never be called -> bug in router
//    completionHandler()
//  }
//
//  
//}

class MainViewRoutable: Routable {
  let navigationController: UINavigationController

  init(_ navigationController: UINavigationController) {
    self.navigationController = navigationController
  }

  func changeRouteSegment(_ from: RouteElementIdentifier, to: RouteElementIdentifier, animated: Bool, completionHandler: @escaping RoutingCompletionHandler) -> Routable {
//    if to == RouteID.menu.rawValue {
//      navigationController.popToRootViewController(animated: true)
//    }
    completionHandler()
    return self
  }

  func pushRouteSegment(
    _ routeElementIdentifier: RouteElementIdentifier,
    animated: Bool,
    completionHandler: @escaping RoutingCompletionHandler) -> Routable {
    if routeElementIdentifier == RouteID.menu.rawValue {
      if !navigationController.topViewController!.isKind(of: MenuTableViewController.self) {
        navigationController.popToRootViewController(animated: true)
      }
      completionHandler()
			return self
    }
    guard let routeID = RouteID.all.filter ({
      $0.rawValue == routeElementIdentifier
    }).first else { fatalError("Cannot handle this route change!") }

    let detailViewController =
      storyboard.instantiateViewController(withIdentifier:
        routeID.storyboardID)
    navigationController.pushViewController(
      detailViewController, animated: true, completion: completionHandler)
    return self
  }

  func popRouteSegment(
    _ routeElementIdentifier: RouteElementIdentifier,
    animated: Bool,
    completionHandler: @escaping RoutingCompletionHandler) {
    // no-op, since this is called when VC is already popped.
    completionHandler()
  }

}

class MenuRoutable: Routable {}
class CategoriesRoutable: Routable {}
class GameRoutable: Routable {}


enum RouteID: RouteElementIdentifier {
  case menu, categories, game
	static let all = [menu, categories, game]

  var storyboardID: String {
    switch self {
    case .menu:				return "MenuTableViewController"
    case .categories: return "CategoriesTableViewController"
    case .game: 			return "GameViewController"
    }
  }

  var routable: Routable {
    switch self {
    case .menu: 			return MenuRoutable()
    case .categories: return CategoriesRoutable()
    case .game:			 	return GameRoutable()
    }
  }
}


