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

import ReSwift
import ReSwiftRouter

final class CategoriesTableViewController: UITableViewController {
  var tableDataSource: TableDataSource<UITableViewCell, Category>?
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // 1
    store.subscribe(self) {
      $0.select {
        $0.categoriesState
      }
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    store.unsubscribe(self)
  }

//  override func didMove(toParentViewController parent: UIViewController?) {
//    if parent == nil {
//      // Required to update the route, when this VC was dismissed through back button from
//      // NavigationController, since we can't intercept the back button
//      if store.state.navigationState.route == [RouteID.menu.rawValue, RouteID.categories.rawValue] {
//        store.dispatch(SetRouteAction([RouteID.menu.rawValue]))
//      }
//    }
//  }

}

extension CategoriesTableViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // 2
    store.dispatch(ChangeCategoryAction(categoryIndex: indexPath.row))
  }
}

extension CategoriesTableViewController: StoreSubscriber {
  func newState(state: CategoriesState) {
    tableDataSource = TableDataSource(cellIdentifier: "CategoryCell", models: state.categories) {
      $0.textLabel?.text = $1.rawValue.capitalized
      // 3
      $0.accessoryType = (state.currentCategorySelected == $1) ? .checkmark : .none
      return $0
    }
    tableView.dataSource = tableDataSource
    tableView.reloadData()
  }
}
