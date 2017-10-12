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

final class GameViewController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let state = store.observable.asObservable()
    
    state.take(1)
      .debug("single")
      .subscribe(onNext: { [weak self ](state) in
        guard let strongSelf = self else { return }
        store.dispatch(fetchTunes(state: state, store: store))
        strongSelf.loadingIndicator.hidesWhenStopped = true
      })
      .disposed(by: rx.disposeBag)
   
    state.skip(1)
      .map { $0.gameState.memoryCards }
      .debug("1")
      .bind(to: collectionView.rx.items(cellIdentifier: "CardCell", cellType: CardCollectionViewCell.self)) {
        (_, card, cell) in
        cell.configCell(with: card)
      }
      .disposed(by: rx.disposeBag)
  
    state.skip(1)
      .debug("2")
      .subscribe(onNext: { [weak self] (state) in
        guard let strongSelf = self else { return }
        state.gameState.showLoading ?
          strongSelf.loadingIndicator.startAnimating() :
          strongSelf.loadingIndicator.stopAnimating()
        if state.gameState.gameFinishied {
          DispatchQueue.main.sync {
            strongSelf.showGameFinishedAlert()
          }
          store.dispatch(fetchTunes(state: state, store: store))
        }
      })
      .disposed(by: rx.disposeBag)
    
    collectionView.rx.itemSelected.asObservable()
      .subscribe(onNext: { (indexPath) in
        store.dispatch(FlipCardAction(cardIndexToFlip: indexPath.row))
      })
      .disposed(by: rx.disposeBag)

  }
  
  fileprivate func showGameFinishedAlert() {
    let alertController = UIAlertController(title: "Congratulations!",
                                            message: "You've finished the game!",
                                            preferredStyle: .alert)
    
    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(defaultAction)
    
    present(alertController, animated: true, completion: nil)
  }
}

