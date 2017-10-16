//
//  StateHistorySliderView.swift
//  Meet
//
//  Created by Benjamin Encz on 12/3/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import UIKit

class StateHistorySliderView: UIView {

    var slider: UISlider!
    var oldSliderValue: Int = 0

    var statesCount: Int = 0 {
        didSet {
            slider.maximumValue = Float(statesCount)
            slider.value = Float(statesCount)
            oldSliderValue = statesCount
        }
    }

    var stateSelectionCallback: ((Int, Bool) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        slider = UISlider(frame: bounds)
        slider.minimumValue = 0
        slider.addTarget(self, action: #selector(StateHistorySliderView.sliderValueChanged), for: .valueChanged)

        addSubview(slider)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    dynamic func sliderValueChanged() {
        let newSliderValue = Int(slider.value)
        var isReverse = false
        if oldSliderValue > newSliderValue {
          isReverse = true
        }
        stateSelectionCallback?(newSliderValue, isReverse)
        oldSliderValue = newSliderValue
    }

}
