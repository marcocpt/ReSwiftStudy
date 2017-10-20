//
//  RecordingStore.swift
//  Meet
//
//  Created by Benjamin Encz on 12/1/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Foundation
import ReactiveReSwift
import RxSwift

public typealias TypeMap = [String: StandardActionConvertible.Type]

open class RecordingMainStore<ObservableProperty: ObservablePropertyType>: Store<ObservableProperty> {

  typealias RecordedActions = [[String : AnyObject]]

  var recordedActions: RecordedActions = []
  var initialState: ObservableProperty.ValueType!
  var computedStates: [ObservableProperty.ValueType] = []
  var actionsToReplay: Int?
  let recordingPath: String?
  fileprivate var typeMap: TypeMap = [:]

  /// Position of the rewind/replay control from the bottom of the screen
  /// defaults to 100
  open var rewindControlYOffset: CGFloat = 100

  var loadedActions: [Action] = [] {
    didSet {
      stateHistoryView?.statesCount = loadedActions.count
    }
  }

  var stateHistoryView: StateHistorySliderView?

  open var window: UIWindow? {
    didSet {
      if let window = window {
        let windowSize = window.bounds.size
        stateHistoryView = StateHistorySliderView(frame:
          CGRect(x: 10, y: windowSize.height - rewindControlYOffset,
                 width: windowSize.width - 20, height: 100))

        window.addSubview(stateHistoryView!)
        window.bringSubview(toFront: stateHistoryView!)

        stateHistoryView?.stateSelectionCallback = { [unowned self] (new) in
          if new == StateHistorySliderView.oldSliderValue {
            return
          }
          if new < StateHistorySliderView.oldSliderValue {
            let actions = self.loadedActions[new..<StateHistorySliderView.oldSliderValue]
            for (index, actionIn) in actions.reversed().enumerated() {
              if let action = actionIn as? RoutingAction {
                var appear = action.appearing
                switch appear.appearType {
                case .pop:
                  appear.appearType = .show
                  appear.from = action.appearing.to
                  appear.to = action.appearing.from
                case .show, .push:
                  appear.appearType = .pop
                  appear.from = action.appearing.to
                  appear.to = action.appearing.from
                case .root:
                  break
                default:
                  appear = action.appearing
                }
                let state = self.computedStates[StateHistorySliderView.oldSliderValue - index] as! AppState
                let routingState = RoutingState(navigatingState: appear)
                let newState = AppState(routingState: routingState,
                                        menuState: state.menuState,
                                        categoriesState: state.categoriesState,
                                        gameState: state.gameState)
                self.observable.value = newState as! ObservableProperty.ValueType
              } else {
                self.observable.value = self.computedStates[new + index]
              }
            }
          } else {
            for index in StateHistorySliderView.oldSliderValue..<new {
              self.observable.value = self.computedStates[index + 1]
              
            }

          }
          StateHistorySliderView.oldSliderValue = new
        }

        stateHistoryView?.statesCount = loadedActions.count
      }
    }
  }

  public init(
    reducer: @escaping StoreReducer,
    observable: ObservableProperty,
    typeMaps: [TypeMap],
    recording: String? = nil,
    middleware: StoreMiddleware = Middleware()
    ) {

    self.recordingPath = recording

    super.init(reducer: reducer, observable: observable, middleware: middleware)

    self.initialState = self.observable.value
    self.computedStates.append(initialState)

    // merge all typemaps into one
    typeMaps.forEach { typeMap in
      for (key, value) in typeMap {
        self.typeMap[key] = value
      }
    }

    if let recording = recording {
      loadedActions = loadActions(recording)
//      self.replayToState(loadedActions, state: loadedActions.count)
    }
  }


  public required init(reducer: @escaping StoreReducer, observable: ObservableProperty, middleware: StoreMiddleware = Middleware()) {
    fatalError("init(reducer:observable:middleware:) has not been implemented")
  }

  func dispatchRecorded(_ action: Action) {
    super.dispatch(action)

    recordAction(action)
  }

  func dispatchSuper(_ action: Action) {
    super.dispatch(action)
  }

  override open func dispatch(_ actions: Action...) {
    actions.forEach {
      if let actionsToReplay = actionsToReplay, actionsToReplay > 0 {
        // ignore actions that are dispatched during replay
        return
      }
      super.dispatch($0)
      self.computedStates.append(observable.value)
      if let standardAction = convertActionToStandardAction($0) {
        recordAction(standardAction)
        loadedActions = loadActions(self.recordingPath!)
//        loadedActions.append(standardAction)
      }
    }
  }

  func recordAction(_ action: Action) {
    let standardAction = convertActionToStandardAction(action)

    if let standardAction = standardAction {
      let recordedAction: [String : AnyObject] = [
        "timestamp": Date.timeIntervalSinceReferenceDate as AnyObject,
        "action": standardAction.dictionaryRepresentation as AnyObject
      ]

      recordedActions.append(recordedAction)
      storeActions(recordedActions)
    } else {
      print("ReSwiftRecorder Warning: Could not log following action because it does not " +
        "conform to StandardActionConvertible: \(action)")
    }
  }

  fileprivate func convertActionToStandardAction(_ action: Action) -> StandardAction? {

    if let standardAction = action as? StandardAction {
      return standardAction
    } else if let standardActionConvertible = action as? StandardActionConvertible {
      return standardActionConvertible.toStandardAction()
    }

    return nil
  }

  fileprivate func decodeAction(_ jsonDictionary: [String : AnyObject]) -> Action {
    let standardAction = StandardAction(dictionary: jsonDictionary)

    if !standardAction!.isTypedAction {
      return standardAction!
    } else {
      let typedActionType = self.typeMap[standardAction!.type]!
      return typedActionType.init(standardAction!)
    }
  }

  lazy var recordingDirectory: URL? = {
    let timestamp = Int(Date.timeIntervalSinceReferenceDate)

    let documentDirectoryURL = try? FileManager.default
      .url(for: .documentDirectory, in:
        .userDomainMask, appropriateFor: nil, create: true)

    //        let path = documentDirectoryURL?
    //            .URLByAppendingPathComponent("recording_\(timestamp).json")
    let path = documentDirectoryURL?
      .appendingPathComponent(self.recordingPath ?? "recording.json")

    print("Recording to path: \(path)")
    return path
  }()

  lazy var documentsDirectory: URL? = {
    let documentDirectoryURL = try? FileManager.default
      .url(for: .documentDirectory, in:
        .userDomainMask, appropriateFor: nil, create: true)

    return documentDirectoryURL
  }()

  fileprivate func storeActions(_ actions: RecordedActions) {
    let data = try! JSONSerialization.data(withJSONObject: actions, options: .prettyPrinted)

    if let path = recordingDirectory {
      try? data.write(to: path, options: [.atomic])
    }
  }

  fileprivate func loadActions(_ recording: String) -> [Action] {
    guard let recordingPath = documentsDirectory?.appendingPathComponent(recording) else {
      return []
    }
    guard let data = try? Data(contentsOf: recordingPath) else { return [] }

    let jsonArray = try! JSONSerialization.jsonObject(with: data,
                                                      options: JSONSerialization.ReadingOptions(rawValue: 0)) as! Array<AnyObject>

    let actionsArray: [Action] = jsonArray.map {
      return decodeAction($0["action"] as! [String : AnyObject])
    }

    return actionsArray
  }

  public func replayToState(_ actions: [Action], state: Int) {
    if (state > computedStates.count - 1) {
      print("Rewind to \(state)...")
      self.observable.value = initialState
      recordedActions = []
      actionsToReplay = state

      for i in 0..<state {
        dispatchRecorded(actions[i])
        self.actionsToReplay = self.actionsToReplay! - 1
        self.computedStates.append(self.observable.value)
      }
    } else {
      self.observable.value = computedStates[state]
    }

  }

}
