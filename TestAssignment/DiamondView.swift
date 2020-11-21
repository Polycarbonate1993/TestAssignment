//
//  DiamondView.swift
//  TestAssignment
//
//  Created by Андрей Гедзюра on 21.11.2020.
//

import Foundation
import UIKit


@IBDesignable
/// UIView deccessor that represents UIView with custom layer mask in shape of polyhedron with customizable corner radius and diagonal edges length.
class DiamondView: UIView {
    /**Corner radius modificator. The higher value the sharper corners. Can't be set below 2. The default value is 10.*/
    @IBInspectable
    var cRadiusMod: CGFloat = 10 {
        didSet {
            setUpLayer()
        }
    }
    /**Diagonal edge's length modificator. The higher value the shorter edge. Can't be set below 1. The default value is 1.*/
    @IBInspectable
    var dLengthMod: CGFloat = 1 {
        didSet {
            setUpLayer()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            setUpLayer()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpLayer()
    }
    /// Creates and sets up CAShapeLayer as a mask layer to the view's layer property.
    private func setUpLayer() {
        let maskLayer = CAShapeLayer()
        layer.mask = maskLayer
        maskLayer.frame = bounds
        let angle = 45 * CGFloat.pi / 180
        let minDimension = min(bounds.width, bounds.height)
        let diagonalLength = (minDimension / 2) / cos(angle) / (dLengthMod < 1 ? 1 : dLengthMod)
        let radius = diagonalLength / (cRadiusMod < 2 ? 2 : cRadiusMod)
        let truncation = radius /** tan(angle / 2)*/
        let xLength = bounds.width - ((diagonalLength * cos(angle)) * 2)
        let yLength = bounds.height - ((diagonalLength * cos(angle)) * 2)
        let startingPoint = CGPoint(x: diagonalLength * cos(angle), y: radius * (1 / cos(angle) - 1))
        let path = UIBezierPath()
        path.flatness = 0.1
        path.move(to: startingPoint)
        path.addLine(to: CGPoint(x: startingPoint.x + xLength, y: startingPoint.y))
        path.addArc(withCenter: CGPoint(x: startingPoint.x + xLength, y: radius / cos(angle)), radius: radius, startAngle: -(CGFloat.pi / 2), endAngle: -(CGFloat.pi / 4), clockwise: true)
        path.addLine(to: CGPoint(x: bounds.width - truncation * cos(angle), y: (diagonalLength - truncation) * cos(angle)))
        path.addArc(withCenter: CGPoint(x: bounds.width - radius / cos(angle), y: diagonalLength * cos(angle)), radius: radius, startAngle: -(CGFloat.pi / 4), endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: bounds.width - radius * (1 / cos(angle) - 1), y: diagonalLength * cos(angle) + yLength))
        path.addArc(withCenter: CGPoint(x: bounds.width - radius / cos(angle), y: diagonalLength * cos(angle) + yLength), radius: radius, startAngle: 0, endAngle: CGFloat.pi / 4, clockwise: true)
        path.addLine(to: CGPoint(x: bounds.width - (diagonalLength - truncation) * cos(angle), y: bounds.height - truncation * cos(angle)))
        path.addArc(withCenter: CGPoint(x: bounds.width - diagonalLength * cos(angle), y: bounds.height - radius / cos(angle)), radius: radius, startAngle: CGFloat.pi / 4, endAngle: CGFloat.pi / 2, clockwise: true)
        path.addLine(to: CGPoint(x: diagonalLength * cos(angle), y: bounds.height - radius * (1 / cos(angle) - 1)))
        path.addArc(withCenter: CGPoint(x: diagonalLength * cos(angle), y: bounds.height - radius / cos(angle)), radius: radius, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi * 0.75, clockwise: true)
        path.addLine(to: CGPoint(x: truncation * cos(angle), y: bounds.height - (diagonalLength - truncation) * cos(angle)))
        path.addArc(withCenter: CGPoint(x: radius / cos(angle), y: bounds.height - diagonalLength * cos(angle)), radius: radius, startAngle: CGFloat.pi * 0.75, endAngle: CGFloat.pi, clockwise: true)
        path.addLine(to: CGPoint(x: radius * (1 / cos(angle) - 1), y: diagonalLength * cos(angle)))
        path.addArc(withCenter: CGPoint(x: radius / cos(angle), y: diagonalLength * cos(angle)), radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 1.25, clockwise: true)
        path.addLine(to: CGPoint(x: (diagonalLength - truncation) * cos(angle), y: truncation * cos(angle)))
        path.addArc(withCenter: CGPoint(x: diagonalLength * cos(angle), y: radius / cos(angle)), radius: radius, startAngle: CGFloat.pi * 1.25, endAngle: CGFloat.pi * 1.5, clockwise: true)
        path.close()
        UIColor.black.set()
        path.fill()
        maskLayer.path = path.cgPath
    }
}
