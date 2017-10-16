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

import ReactiveReSwift

let routingActionTypeMap: TypeMap = [RoutingAction.type : RoutingAction.self]

struct RoutingAction: StandardActionConvertible {
  let destination: RoutingDestination
  let source: RoutingDestination
  let type: RoutingType

  static let type = "ROUTING_ACTION"

  init(destination: RoutingDestination, source: RoutingDestination, type: RoutingType) {
    self.destination = destination
    self.source = source
    self.type = type
  }

  init(_ standardAction: StandardAction) {
    let rawDestination = standardAction.payload!["destination"] as! String
    let rawSource = standardAction.payload!["source"] as! String
    let rawType = standardAction.payload!["type"] as! String
    self.destination = RoutingDestination(rawValue: rawDestination)!
    self.source = RoutingDestination(rawValue: rawSource)!
    self.type = RoutingType(rawValue: rawType)!
    
  }

  func toStandardAction() -> StandardAction {
    let payload = [
      "destination" : destination.rawValue as AnyObject,
      "source"      : source.rawValue as AnyObject,
      "type"        : type.rawValue as AnyObject]
    return StandardAction(type: RoutingAction.type, payload: payload, isTypedAction: true)
  }

}
