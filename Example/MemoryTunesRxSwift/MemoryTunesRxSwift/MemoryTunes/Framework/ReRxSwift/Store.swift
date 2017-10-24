//
//  Store.swift
//  ReactiveReSwift
//
//  Created by Charlotte Tortorella on 11/17/16.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import Foundation
import RxSwift

open class Store<State: StateType> {

    public typealias StoreMiddleware = Middleware<State>
    public typealias StoreReducer = Reducer<State>

    private(set) var observable: Variable<State>
    private let middleware: StoreMiddleware
    private let reducer: StoreReducer

    public required init(reducer: @escaping StoreReducer, observable: Variable<State>, middleware: StoreMiddleware = Middleware()) {
        self.reducer = reducer
        self.observable = observable
        self.middleware = middleware
    }

    public func dispatch(_ actions: Action...) {
        actions.forEach { action in
            let dispatchFunction: (Action...) -> Void = { [weak self] (actions: Action...) in
                actions.forEach { self?.dispatch($0) }
            }
            middleware.transform({ self.observable.value }, dispatchFunction, action).forEach { action in
                observable.value = reducer(action, observable.value)
            }
        }
    }

}
