//
//  CountdownProgressView.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 24/07/2023.
//

import UIKit

class CountdownProgressView: UIProgressView {
    override func layoutSubviews() {
        super.layoutSubviews()

        let maskLayerPath = UIBezierPath(roundedRect: bounds, cornerRadius: 20.0)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskLayerPath.cgPath
        layer.mask = maskLayer
    }
}
