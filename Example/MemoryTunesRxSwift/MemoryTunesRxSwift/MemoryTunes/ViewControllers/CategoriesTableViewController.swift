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
import ReactiveReSwift

final class CategoriesTableViewController: UITableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.do {
      $0.dataSource = nil
      $0.delegate = nil
      $0.rx.setDelegate(self).disposed(by: rx.disposeBag)
    }
    bind()
  }
  
  func bind() {
    store.observable.asObservable()
      .map { $0.categoriesState }
      .map { state in
        state.categories
          .map { ($0, state.currentCategorySelected) }
      }
      .bind(to: tableView.rx.items(cellIdentifier: "CategoryCell")) {
        (_, categoryTuple , cell) in
        cell.textLabel?.text = categoryTuple.0.rawValue.capitalized
        cell.accessoryType = (categoryTuple.1 == categoryTuple.0) ?
          .checkmark : .none
      }
      .disposed(by: rx.disposeBag)
    
    tableView.rx.itemSelected.asObservable()
      .subscribe(onNext: { indexPath in
        store.dispatch(ChangeCategoryAction(categoryIndex: indexPath.row))
      })
      .disposed(by: rx.disposeBag)
      
  }
  
  
}
