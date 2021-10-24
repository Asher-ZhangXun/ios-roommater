//
//  UIComponents.swift
//  Roommater
//
//  Created by Asher Xun Zhang on 10/14/21.
//
let overcastBlueColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)

import Foundation
import UIKit

let WIDTH:CGFloat = UIScreen.main.bounds.width
let HEIGHT:CGFloat = UIScreen.main.bounds.height

let mailPattern = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
let mailMatcher = MyRegex(mailPattern)






class NoNullTextField: UITextField{
//    func showToolTip() {
//        let tipWidth: CGFloat = 200
//        let tipHeight: CGFloat = 80
//        let tipX = self.frame.midX - tipWidth / 2
//        let tipY: CGFloat = self.frame.minY - tipHeight
//        let tipView = ToolTipView(frame: CGRect(x: tipX, y: tipY, width: tipWidth, height: tipHeight), text: "Hello User! This is a sample tool tip", tipPos: .middle)
//       UIApplication.shared.keyWindow?.addSubview(tipView)
//        UIApplication.shared.keyWindow?.removeFromSuperview()
//       performShow(tipView)
//    }
//    func performShow(_ v: UIView?) {
//       v?.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
//       UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
//         v?.transform = .identity
//       })
//    }
}
class UsernameTextField: NoNullTextField{
}
class PasswordTextField: NoNullTextField{
}
class RePasswordTextField: NoNullTextField{
}
class EmailTextField: NoNullTextField{
}
class PrototypeViewController: UIViewController{
    
    func viewLoadAction(){}
    override func viewDidLoad() {
        super.viewDidLoad()
        viewLoadAction()
    }
}

extension PrototypeViewController: UITextFieldDelegate{
    
    @objc func textFieldDone(_ textField: UITextField){}
    
    @objc func textFieldAction(_ textField: UITextField){}
    
    @objc func textFieldAvailableCheck(_ textField: UITextField)->Bool {return true}
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag+1
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textFieldDone(textField)
            keyboardDisappearAction(textField)
            unableAllTextField()
        }
        return true
    }
    
    func unableAllTextField(){
        self.view.subviews.filter {$0 is UITextField}.forEach {
            item in item.isUserInteractionEnabled = false
        }
    }
    
    func enableAllTextField(){
        self.view.subviews.filter {$0 is UITextField}.forEach {
            item in item.isUserInteractionEnabled = true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        keyboardDisappearAction(textField)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textFieldAction(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldAvailableCheck(textField)
        textFieldAction(textField)
    }
    
    
    func keyboardAppearAction(_ textField: UITextField){
        if (textField.frame.midY > (HEIGHT/2)){
            UIView.animate(withDuration: 0.3, animations: {
            self.view.frame.origin.y = 0
            })
        }
    }
    func keyboardDisappearAction(_ textField: UITextField){
        if (textField.frame.midY > (HEIGHT/2)){
            UIView.animate(withDuration: 0.4, animations: {
            self.view.frame.origin.y = -150
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.3, animations: {
        self.view.frame.origin.y = 0
        })
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}

class PrototypeButton:UIButton{
    func notAvailableAction(){
        notAvailableUI()
    }
    @objc func notAvailableUI(){
        self.isEnabled = false
        self.backgroundColor = .systemGray5
        self.setTitleColor(.systemGray3, for: .normal)
    }
    
    func availableAction(){
        availableUI()
    }
    @objc func availableUI(){
        self.isEnabled = true
        self.backgroundColor = .systemBlue
        self.setTitleColor(.white, for: .normal)
    }
}

struct MyRegex {
    let regex: NSRegularExpression?
     
    init(_ pattern: String) {
        regex = try? NSRegularExpression(pattern: pattern,
                                         options: .caseInsensitive)
    }
     
    func match(input: String) -> Bool {
        if let matches = regex?.matches(in: input,
            options: [],
            range: NSMakeRange(0, (input as NSString).length)) {
                return matches.count > 0
        } else {
            return false
        }
    }
}

//enum ToolTipPosition: Int {
//     case left
//     case right
//     case middle
//}
//class ToolTipView: UIView {
//
//    var roundRect:CGRect!
//    let toolTipWidth : CGFloat = 20.0
//    let toolTipHeight : CGFloat = 12.0
//    let tipOffset : CGFloat = 20.0
//    var tipPosition : ToolTipPosition = .middle
//
//    convenience init(frame: CGRect, text : String, tipPos: ToolTipPosition){
//       self.init(frame: frame)
//       self.tipPosition = tipPos
//       createLabel(text)
//    }
//
//    func createLabel(_ text : String){
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: self.frame.height - self.toolTipHeight))
//        label.text = text
//        label.textColor = .white
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        label.lineBreakMode = .byWordWrapping
//        addSubview(label)
//    }
//
//    func createTipPath() -> UIBezierPath{
//        let tooltipRect = CGRect(x: roundRect.midX, y: roundRect.maxY, width: toolTipWidth, height: toolTipHeight)
//       let trianglePath = UIBezierPath()
//       trianglePath.move(to: CGPoint(x: tooltipRect.minX, y: tooltipRect.minY))
//       trianglePath.addLine(to: CGPoint(x: tooltipRect.maxX, y: tooltipRect.minY))
//       trianglePath.addLine(to: CGPoint(x: tooltipRect.midX, y: tooltipRect.maxY))
//       trianglePath.addLine(to: CGPoint(x: tooltipRect.minX, y: tooltipRect.minY))
//       trianglePath.close()
//       return trianglePath
//    }
//
//    func drawToolTip(_ rect : CGRect){
//        roundRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height - self.toolTipHeight)
//       let roundRectBez = UIBezierPath(roundedRect: roundRect, cornerRadius: 5.0)
//       let trianglePath = createTipPath()
//       roundRectBez.append(trianglePath)
//       let shape = createShapeLayer(roundRectBez.cgPath)
//       self.layer.insertSublayer(shape, at: 0)
//    }
//
//    func createShapeLayer(_ path : CGPath) -> CAShapeLayer{
//       let shape = CAShapeLayer()
//       shape.path = path
//       shape.fillColor = UIColor.darkGray.cgColor
//       shape.shadowColor = UIColor.black.withAlphaComponent(0.60).cgColor
//       shape.shadowOffset = CGSize(width: 0, height: 2)
//       shape.shadowRadius = 5.0
//       shape.shadowOpacity = 0.8
//       return shape
//    }
//
//    override func draw(_ rect: CGRect) {
//       super.draw(rect)
//       drawToolTip(rect)
//    }
//}


