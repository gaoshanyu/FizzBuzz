//
//  UIExtension.swift
//
//  Created by raniys on 8/25/16.
//  Copyright © 2016 raniys. All rights reserved.
//

import UIKit
import ImageIO

public extension UIColor {
    
    // hex sample: 0xf43737
    convenience init(hex: Int, alpha: Double = 1.0) {
        self.init(red: CGFloat((hex>>16)&0xFF)/255.0, green: CGFloat((hex>>8)&0xFF)/255.0, blue: CGFloat((hex)&0xFF)/255.0, alpha: CGFloat(255 * alpha) / 255)
    }
    
    convenience init(hexString: String, alpha: Double = 1.0) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(255 * alpha) / 255)
    }
    
}

public extension CGSize {
    func scale(for targetSize: CGSize) -> CGSize {
        let widthRatio  = targetSize.width  / self.width
        let heightRatio = targetSize.height / self.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: self.width * heightRatio, height: self.height * heightRatio)
        } else {
            newSize = CGSize(width: self.width * widthRatio, height: self.height * widthRatio)
        }
        return newSize
    }
}

public extension UIImage {
    
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    /// To make screenshot
    ///
    /// - returns: image of screenshot
    public class var screenShot: UIImage {
        
        let window = UIApplication.shared.keyWindow
        
        if UIScreen.main.responds(to: #selector(NSDecimalNumberBehaviors.scale)) {
            
            UIGraphicsBeginImageContextWithOptions(window!.bounds.size, false, UIScreen.main.scale)
            
        } else {
            
            UIGraphicsBeginImageContext(window!.bounds.size)
            
        }
        
        window?.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    /// To make the image always up
    ///
    /// - returns: image of corrected
    func transformImageTocorrectDirection() -> UIImage {
        
        UIGraphicsBeginImageContext(self.size)
        self.draw(at: .zero)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
        
    }

    /// To do compressionQuality for image and return the imageData of compressed
    ///
    /// - Parameter byte: Request data size (e.g. 1MB = 1024 * 1024 byte)
    /// - Returns: image data
    public func imageRepresentationWithByteSize(byte: Int) -> Data? {
        
        guard var imageData = self.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        
        var i: Double = 5
        while imageData.count > byte && i > 0 {
            i -= 1
            imageData = self.jpegData(compressionQuality: CGFloat(0.2*(i)))!
        }
        
        return imageData
    }
    
    /// To do compressionQuality for image and return the imageData of compressed
    ///
    /// - Parameter byte: Request image size (e.g. 1MB = 1024 * 1024 byte)
    /// - Returns: request image
    func imageRepresentationJpegWithByteSize(byte: Int) -> UIImage? {
        
        guard let imageData = imageRepresentationWithByteSize(byte: byte) else {
            return nil
        }
        
        return UIImage(data: imageData)
    }
    
    /// Resize image with the biggest value the sent, the value should use for Width/Height of the result Image(e.g. sizeValue = 300, means the Width/Height biggest value is 300, and the Height/Width value should small/equal to the other one). Please be attention: the image storage would be changed after the resize, but not clean of the changing value
    ///
    /// - Parameter sizeValue: the request biggest value of the width/height of the result image
    /// - Returns: request image
    func imageResizeWithConstantSize(sizeValue: CGFloat) -> UIImage {
        
        if self.size.width > sizeValue || self.size.height > sizeValue {
            
            var btWidth: CGFloat = 0.0
            var btHeight: CGFloat = 0.0
            
            if self.size.width > self.size.height {
                btHeight = sizeValue
                btWidth = self.size.width * (sizeValue / self.size.height)
            } else {
                btWidth = sizeValue
                btHeight = self.size.height * (sizeValue / self.size.width)
            }
            
            let targetSize = CGSize(width: btWidth, height: btHeight)
            return UIImage.resizeImage(image: self, targetSize: targetSize)!
        }
        
        return self
    }
    
    /// To resize the image as the targetSize, the storage of the image should be changed but not clean of the changing value
    ///
    /// - Parameters:
    ///   - image: the source image which should be resized
    ///   - targetSize: the size requested of the result image
    /// - Returns: request image
    public class func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    public class func gifImageWithData(data: NSData) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source: source)
    }
    
    public class func gifImageWithURL(gifUrl:String) -> UIImage? {
        guard let bundleURL:URL = URL(string: gifUrl)
            else {
                print("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = NSData(contentsOf: bundleURL) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        if bundleURL.pathExtension == "gif" {
            return gifImageWithData(data: imageData)
        } else {
            return UIImage(data: imageData as Data)
        }
    }
    
    public class func gifImageWithName(name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = NSData(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(data: imageData)
    }
    
    class func delayForImageAtIndex(index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(
                CFDictionaryGetValue(gifProperties,
                                     Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()),
                to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a! < b! {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(a: val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(index: Int(i),
                                                            source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(array: delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
                                              duration: Double(duration) / 1000.0)
        
        return animation
    }
}


public extension UIView {
    
    /// To find the parent ViewController for current view
    public var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    class func fromNib<T : UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

public extension UIViewController {
    
    func showNotifyAlert(title: String?, message: String?, completion: (() -> Swift.Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert )
        
        let yesAction = UIAlertAction(title: "确认", style: .default) { (action) in
            completion?()
        }
        
        alert.addAction(yesAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showConfirmModel(title: String?, message: String?, okTitle: String = "确认", noTitle: String = "取消", completion: @escaping (_ isOK: Bool) -> ()) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert )
        
        let yesAction = UIAlertAction(title: okTitle, style: .default) { (action) in
            completion(true)
        }
        
        let noAction = UIAlertAction(title: noTitle, style: .cancel) { (action) in
            completion(false)
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /// draw a red cycle on tabbar item
    func setTabBarBadgeVisible(visible:Bool, index: Int? = nil) {
        
        let tabBarController:UITabBarController!
        
        if self is UITabBarController {
            tabBarController = self as! UITabBarController
        } else {
            if self.tabBarController == nil { return }
            tabBarController = self.tabBarController!
        }
        
        let indexFinal:Int
        if (index != nil) {
            
            indexFinal = index!
            
        } else {
            let index3 = tabBarController.viewControllers?.firstIndex(of: self)
            if index3 == nil {
                return;
            } else {
                indexFinal = index3!
            }
        }
        
        guard let barItems = tabBarController.tabBar.items else { return }
        
        let tag = 8888
        var tabBarItemView:UIView?
        
        for subview in tabBarController.tabBar.subviews {
            
            let className = String(describing: type(of: subview))
            
            guard className == "UITabBarButton" else {
                continue
            }
            
            var label:UILabel?
            var dotView:UIView?
            
            for subview2 in subview.subviews {
                
                if subview2.tag == tag {
                    dotView = subview2;
                }
                else if (subview2 is UILabel)
                {
                    label = subview2 as? UILabel
                }
            }
            
            if label?.text == barItems[indexFinal].title
            {
                dotView?.removeFromSuperview()
                tabBarItemView = subview;
                break;
            }
        }
        
        if (tabBarItemView == nil || !visible) { return }

        let barItemWidth = tabBarItemView!.bounds.width
        
        let x = barItemWidth * 0.5 + (barItems[indexFinal].selectedImage?.size.width ?? barItemWidth) / 2
        let y:CGFloat = 5
        let size:CGFloat = 10;
        
        let redDot = UIView(frame: CGRect(x: x, y: y, width: size, height: size))
        
        redDot.tag = tag
        redDot.backgroundColor = UIColor.red
        redDot.layer.cornerRadius = size/2
        
        
        tabBarItemView!.addSubview(redDot)
    }
}

extension UITextField {
    func clearButtonWithImage(_ image: UIImage) {
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(image, for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(self.clear(sender:)), for: .touchUpInside)
        self.rightView = clearButton
        self.rightViewMode = .whileEditing
    }
    
    @objc func clear(sender : AnyObject) {
        self.text = ""
    }
    
    func leftViewWithImage(_ image: UIImage, contentMode: UIView.ContentMode = .center, offset: CGFloat = 12) {
        let leftView = UIImageView(image: image)
        if let size = leftView.image?.size {
            leftView.frame = CGRect(x: 0, y: 0, width: size.width + offset * 2, height: size.height)
        }
        leftView.contentMode = contentMode
        
        self.leftView = leftView
        self.leftViewMode = .always
    }
}

public extension UIDevice {
    
    /// pares the deveice name as the standard name
    var modelName: String {
        
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
        #else
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8 , value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
        #endif
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        default:                                        return identifier
        }
    }
    
}
