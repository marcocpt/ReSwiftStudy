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
    static var oldSliderValue = 0

    var statesCount: Int = 0 {
        didSet {
            slider.maximumValue = Float(statesCount)
            slider.value = Float(statesCount)
            StateHistorySliderView.oldSliderValue = Int(slider.maximumValue)
        }
    }

    var stateSelectionCallback: ((Int) -> Void)?

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
        stateSelectionCallback?(Int(slider.value))
    }

}
