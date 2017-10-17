/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

import RxSwift
import NSObject_Rx

final class AppRouter {
  
  weak var navigationController: UINavigationController!

  private let disposeBag = DisposeBag()
  
  init(window: UIWindow) {
    
    store.observable.asObservable()
      .skip(1)
      .map { $0.routingState }
      .skipWhile { $0.typeState != .root }
      .distinctUntilChanged()
      .debug("routingState")
      .subscribe(onNext: { [weak self](state) in
        guard let strongSelf = self else { return }
        switch state.typeState {
        case .root:
          let root = strongSelf.instantiateViewController(identifier: state.navigationState.rawValue)
          strongSelf.navigationController = UINavigationController(rootViewController: root)
          window.rootViewController = strongSelf.navigationController
        case .show:
          strongSelf.pushViewController(identifier: state.navigationState.rawValue, animated: false)
        case .pop:
          strongSelf.navigationController.popViewController(animated: false)
        default :
          break
        }
      })
    	.disposed(by: disposeBag)
  }

  // 2
  fileprivate func  pushViewController(identifier: String, animated: Bool) {
    let viewController = instantiateViewController(identifier: identifier)
    let newViewControllerType = type(of: viewController)
    if let currentViewController = navigationController.topViewController {
      let currentViewControllerType = type(of: currentViewController)
      if currentViewControllerType == newViewControllerType {
        return
      }
    }
    navigationController.pushViewController(viewController, animated: animated)
  }

  fileprivate func instantiateViewController(identifier: String) -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    return storyboard.instantiateViewController(withIdentifier: identifier)
  }

}

extension UINavigationController: UINavigationBarDelegate {
  public func navigationBar(_ navigationBar: UINavigationBar, didPop item: UINavigationItem) {
    guard let source = store.computedStates.last?.routingState.navigationState else { fatalError() }
    var destinationString = ""
    if let top = self.topViewController{
      destinationString = type(of: top).description().components(separatedBy: ".").last!
    }
    let destination = RoutingDestination(rawValue: destinationString)!
    store.dispatch(RoutingAction(destination: destination, source: source ,appearType: .systemPop))
    
  }
}

enum RoutingDestination: String {
  case menu = "MenuTableViewController"
  case game = "GameViewController"
  case categories = "CategoriesTableViewController"
  case test = "TestViewController"
  case none = ""
}

enum RoutingType: String {
  case root, push, modal, show, pop, systemPop
}
