//
//  Store+extensions.swift
//  MemoryTunes
//
//  Created by wgd on 13/10/2017.
//  Copyright © 2017 raywenderlich. All rights reserved.
//

import ReactiveReSwift

extension Store {
  public typealias ActionCreator = (_ state: ObservableProperty.ValueType, _ store: Store) -> Action

  func dispatch(_ actionCreatorProvider: @escaping ActionCreator) {
    dispatch(actionCreatorProvider(observable.value, self))
  }
  
}
