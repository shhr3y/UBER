//
//  Extensions.swift
//  UBER
//
//  Created by Shrey on 04/07/20.
//  Copyright © 2020 Shrey. All rights reserved.
//

import UIKit
import MapKit

extension UIView {
    
    func addShadow(){
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.55
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.masksToBounds = false
    }
    
    func inputContainerView(image: UIImage, textField: UITextField? = nil, segmentedControl: UISegmentedControl? = nil) -> (UIView){
        let view = UIView()
        
        let icon = UIImageView()
        icon.image = image
        icon.alpha = 0.87
        view.addSubview(icon)
        
        if let textField = textField {
            icon.centerY(inView: view)
            icon.anchor(left: view.leftAnchor, paddingLeft: 8, width: 24, height: 24)
            view.addSubview(textField)
            textField.centerY(inView: view)
            textField.anchor(top: view.topAnchor, left: icon.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 8,  paddingRight: 8)
            let separator = UIView()
            separator.backgroundColor = .lightGray
            view.addSubview(separator)
            separator.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, height: 1)
        }
        
        if let segmentedControl = segmentedControl {
            icon.anchor(top: view.topAnchor, left: view.leftAnchor,paddingTop: 8, paddingLeft: 8, width: 24, height: 24)
            
            let label = UILabel()
            label.text = "You are a Rider or Driver?"
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = .lightGray
            view.addSubview(label)
            label.anchor(top: view.topAnchor, left: icon.rightAnchor, right: view.rightAnchor,paddingTop: 10, paddingLeft: 8, paddingRight: 8)
            
            
            view.addSubview(segmentedControl)
            segmentedControl.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 8, paddingRight: 8)
            segmentedControl.centerY(inView: view)
            segmentedControl.centerX(inView: view)
        }
        
        return view
    }
    
    
    
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil){
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func centerX(inView view: UIView, constant: CGFloat = 0){
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: constant).isActive = true
    }
    
    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil, leftPadding: CGFloat = 0, constant: CGFloat = 0){
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let left = leftAnchor {
            anchor(left: left, paddingLeft: leftPadding)
        }
    }
    
    func setDimensions(height: CGFloat, width: CGFloat){
        translatesAutoresizingMaskIntoConstraints = false
        
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
}


extension UITextField {
    
    func textField(withPlaceholder placeholder:String, isSecureText:Bool) ->(UITextField){
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .white
        tf.keyboardAppearance = .dark
        tf.isSecureTextEntry = isSecureText
        tf.autocapitalizationType = .none
        tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        return tf
    }
}


extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }
    
    static let backgroundColor = UIColor.rgb(red: 25, green: 25, blue: 25)
    static let mainBlueTint = UIColor.rgb(red: 17, green: 154, blue: 237)
    static let outlineStrokeColor = UIColor.rgb(red: 234, green: 46, blue: 111)
    static let trackStrokeColor = UIColor.rgb(red: 56, green: 25, blue: 49)
    static let pulsatingFillColor = UIColor.rgb(red: 86, green: 30, blue: 63)
}


extension MKPlacemark {
    var address: String? {
        get{
            guard let subThoroughfare = subThoroughfare else { return nil }
            guard let thoroughfare = thoroughfare else { return nil }
            guard let locality = locality else { return nil }
            guard let administrativeArea = administrativeArea else { return nil }
            
            return  "\(subThoroughfare) \(thoroughfare), \(locality), \(administrativeArea)"
        }
    }
}


extension MKMapView {
    func zoomToFit(annotations: [MKAnnotation]) {
        var zoomRect = MKMapRect.null
        
        annotations.forEach { (annotation) in
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect =  MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01)
            zoomRect = zoomRect.union(pointRect)
        }
        
        let insets = UIEdgeInsets(top: 100 , left: 100, bottom: 250, right: 100)
        setVisibleMapRect(zoomRect, edgePadding: insets, animated: true)
    }
}


extension UIViewController {
    
    func presentAlertController(withTitle title: String, withMessage message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func shouldPresentLoadingView(_ present: Bool, message: String? = nil){
        print("DEBUG: shouldPresentLoadingView called")
        if present{
            let loadingView = UIView()
            loadingView.frame = self.view.frame
            loadingView.backgroundColor = .black
            loadingView.alpha = 0
            loadingView.tag = 1
            
            let indicator = UIActivityIndicatorView()
            indicator.style = UIActivityIndicatorView.Style.large
            indicator.color = .white
            indicator.center = view.center
            
            let label = UILabel()
            label.text = message
            label.font = UIFont.systemFont(ofSize: 20)
            label.textAlignment = .center
            label.alpha = 0.87
            label.textColor = .white
            
            loadingView.addSubview(indicator)
            loadingView.addSubview(label)
            view.addSubview(loadingView)
            
            label.centerX(inView: view)
            label.anchor(top: indicator.bottomAnchor, paddingTop: 32)
            
            indicator.startAnimating()
            
            UIView.animate(withDuration: 0.3) {
                loadingView.alpha = 0.7
            }
        }else{
            view.subviews.forEach { (subview) in
                if subview.tag == 1 {
                    UIView.animate(withDuration: 0.3, animations: {
                        subview.alpha = 0
                    }) { (_) in
                        subview.removeFromSuperview()
                    }
                }
            }
        }
    }
}
