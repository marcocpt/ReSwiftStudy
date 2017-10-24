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

//import ReactiveReSwift

let routingActionTypeMap: TypeMap = [RoutingAction.type : RoutingAction.self]

typealias Appear = (from: RoutingDestination, appearType: RoutingType,
  									to: RoutingDestination)
struct RoutingAction: StandardActionConvertible {
  let appearing: Appear

  static let type = "ROUTING_ACTION"

  init(appearing: Appear) {
    self.appearing = appearing
  }

  init(_ standardAction: StandardAction) {
    let appearing = standardAction.payload!["appearing"] as! [String]
    let from = RoutingDestination(rawValue: appearing[0])!
    let appearType = RoutingType(rawValue: appearing[1])!
    let to = RoutingDestination(rawValue: appearing[2])!
    self.appearing = (from, appearType, to)
    
  }

  func toStandardAction() -> StandardAction {
    let appearingAny = [appearing.from.rawValue, appearing.appearType.rawValue,
                        appearing.to.rawValue] as AnyObject
    let payload = ["appearing": appearingAny]
    return StandardAction(type: RoutingAction.type, payload: payload,
                          isTypedAction: true)
  }
  
}
