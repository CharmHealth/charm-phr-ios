//
//  Extensions.swift
//  phr
//
//  Created by Sankar Saravanan on 11/10/19.
//  Copyright © 2019 Dhanuprasanya P. All rights reserved.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

extension Array where Element: Hashable {
    func removeDuplicateElements() -> Array {
        var temp = Array()
        var s = Set<Element>()
        for i in self {
            if !s.contains(i) {
                temp.append(i)
                s.insert(i)
            }
        }
        return temp
    }
}

extension Array {
    func firstOrNil() -> Element? {
        if !self.isEmpty {
            return self[0]
        }
        return nil
    }
    func lastOrNil() -> Element? {
        if !self.isEmpty {
            return self[self.count - 1]
        }
        return nil
    }
    func getElement(at index: Int) -> Element? {
            let isValidIndex = index >= 0 && index < count
            return isValidIndex ? self[index] : nil
    }
    func indexOf(includedElement: (Element) -> Bool) -> Int? {
        
        for (idx, element) in enumerated() {
            if includedElement(element) {
                return idx
            }
        }
        return nil
    }
    
    mutating func removeFirst(count: Int) -> [Element] {
        let countToRemove = Swift.min(count, self.count)
        let removedItems = Array(self.prefix(countToRemove))
        removeFirst(countToRemove)
        return removedItems
    }
    
    func getFirst(_ n: Int) -> [Element] {
        guard n > 0 && !isEmpty else { return [] }
        let count = Swift.min(n, self.count)
        return Array(self[0..<count])
    }
}

extension Collection {
    func index(of index: Index) -> Int { distance(from: startIndex, to: index) }
}

extension String {
    
    func subString(from: Int) -> String {
        let to = self.count
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[startIndex..<endIndex])
    }
    
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            }
            catch {
                debugPrintLog(error.localizedDescription)
            }
        }
        return nil
    }
    
    var convertHtmlToNSAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            debugPrintLog(error.localizedDescription)
            return nil
        }
    }
    
    func isValidEmail() -> Bool {

        let emailFormat = "[0-9a-z._%+-]+@[a-z0-9.-]+\\.[a-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func removeStar() -> String?{
        if self.hasSuffix("*") == true {
            let str = NSMutableAttributedString(string: self)
            str.deleteCharacters(in: NSRange(location: str.length - 2, length: 2))
            return str.string
        }
        return self
    }
    
    func formInitials() -> String {
        var initials = ""
            
        self.components(separatedBy: " ").filter({str in
            str.isNotBlank() && str.firstOrNil()?.isLetter == true
        }).forEach({ str in
            initials += "\(str.firstOrNil() ?? " ")".uppercased().trim()
        })
        return initials
    }
    
    func trimLeadingSpaces() -> String {
            var newString = self

            while newString.first?.isWhitespace == true {
                newString = String(newString.dropFirst())
            }
            return newString
        }

    func getIntFromString() -> Int?{
        var intString: String = ""
        for char in self{
            if char.isNumber{
                intString.append("\(char)")
            }
        }
        return intString.toIntOrNil()
    }
    
    func isNumber() -> Bool{
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    func capitalizingFirstLetter() -> String { // to be removed
        
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
    
    func hasAnyAlphabets() -> Bool {
        let letters = NSCharacterSet.letters

        let range = self.rangeOfCharacter(from: letters)

        return range != nil// range will be nil if no letters is found
//        if let test = range {
//
//        }
//        else {
//
//        }
    }
    
    
    func toInt64OrNil() -> Int64? {
        return Int64(self)
    }

    func isValidHtmlString() -> Bool {
        if self.isEmpty {
            return false
        }
        return (self.range(of: "<(\"[^\"]*\"|'[^']*'|[^'\">])*>", options: .regularExpression) != nil)

    }
    
    func firstOrNil() -> Character?{
        
        if isEmpty {
            return nil
        }
        
        return self.first
    }
    
    func toIntOrNil() -> Int? {
        return Int(self)
    }
    
    func toFloatOrNil() -> Float? {
        return Float(self)
    }
    func toDoubleOrNil() -> Double? {
        return Double(self)
    }
    func trim() -> String {
            return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func trimAllSpaces() -> String{
       return String(self.filter { !" \n\t\r".contains($0) })
    }
    
    func truncate(length: Int) -> String {
      return (self.count > length) ? self.prefix(length) + "" : self
    }
    
    public func urlEncode() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    
    func isBlank() -> Bool{
        return self.trim().isEmpty
    }
    
    func isNotBlank() -> Bool{
        return !isBlank()
    }
    
    func index(from: Int) -> Index {
            return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    func validateEmail() -> Bool {
        let REGEX: String
        REGEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        return NSPredicate(format: "SELF MATCHES %@", REGEX).evaluate(with: self)
    }
}

extension Character {
    
    func isDigit() -> Bool{
        return isASCII && isNumber
    }
}

extension Optional where Wrapped == String {
    func isNilOrBlank() -> Bool{
        return  self?.isBlank() ?? true
    }
}

extension Dictionary where Key == String {
    
    func getAsJsonObject(_ key: String) -> Dictionary<String , Any>?{
        return self[key] as? Dictionary<String, Any>
    }
    
    func getAsJsonArray(_ key: String) -> [Dictionary<String , Any>]?{
        return self[key] as? [Dictionary<String, Any>]
    }
    
    func getAsStringArray(_ key: String) -> [String]?{
        return self[key] as? [String]
    }
    
    func convertToStringJson() -> String?{
       
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: self,
            options: []) {
            let response = String(data: theJSONData,
                                       encoding: .utf8)
           return response
        }
        return nil
    }
    
    func getString(_ key: String) -> String? {
        if let value = self[key] as? String {
            return value
        }
        else{
            if let value = self[key] as? Int {
                return "\(value)"
            }
            else{
                if let value = self[key] as? Float {
                    return "\(value)"
                }
                else{
                    if let value = self[key] as? Bool {
                        return "\(value)"
                    }
                }
            }
        }

        
       return nil//self[key] as? String
    }
    
    func getDouble(_ key: String) -> Double? {
       return self[key] as? Double
    }
    
    func getBoolean(_ key: String) -> Bool? {
       
        if let value = self[key] as? Bool {
            return value
        }
        else{
            if let valueStr = self[key] as? String {
                
                if valueStr.lowercased() == "true"  {
                    return true
                }
                else{
                    return false
                }
            }
            
            if let valInt = self[key] as? Int {
                if valInt == 0{
                    return false
                }
                else{
                    return true
                }
            }
        }
        
       return nil
    }
    
    func getInt(_ key: String) -> Int? {
        if let value = self[key] as? Int {
            return value
        }
        else{
            if let valueStr = self[key] as? String {
                return valueStr.toIntOrNil()
            }
        }
       return nil
    }
    
    mutating func addProperty(_ key: String ,_ value: Value?, isAllowNil: Bool = false) {
        
        if isAllowNil{
            self[key] = value
        }
        else{
            if value != nil {
                self[key] = value
            }
        }
    }
}

extension Data
{
    mutating func appendString(string: String)
    {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
    
    
}

extension Double {
    
    func roundToTwo() -> Double? {
        
        //        let string =  String(format: "%.2f", self)
        //        return string.toDoubleOrNil()
        
        let value = self
        return CharmUtil.roundToTwo(value: value) //floor(value * 100.00)/100.00
    }
    
    func roundToTwoStr() -> String {
        
        if let round = roundToTwo() {
            var string =  "\(round)"
            if let decimalStr = string.components(separatedBy: ".").getElement(at: 1){
                if decimalStr.count == 1 && decimalStr != "0"{
                    string.append("0")
                }
                else if decimalStr.count == 1 && decimalStr == "0" {
                    return string.components(separatedBy: ".").getElement(at: 0) ?? ""
                }
            }
            
            return string
        }
        
        
        return ""
    }
}

extension UIFont
{
    class func systemFont(ofSize fontSize:CGFloat, Weight: UIFont.FontWeight) -> UIFont
    {
        return UIFont(name:Weight.fontName() , size: fontSize)!
    }
   
    public enum FontWeight : String {
        case regular = "OpenSans-Regular"
        case bold = "OpenSans-Bold"
        case semibold = "OpenSans-SemiBold"
        case light = "OpenSans-Light"
        case italic = "OpenSans-Italic"
        case boldItalic = "OpenSans-BoldItalic"
        case medium = "OpenSans-Medium"

        
        func fontName() -> String
        {
            return "\(self.rawValue)"
        }
    }
}

extension UIImageView{
    func getModifiedImage(tintColor: UInt) -> UIImage?{
        let image = self.image?.withTintColor(UIColorFromRGB(rgbValueWithAlpha: tintColor))
        return image
    }
}

extension UILabel
{
    func addImage(image: UIImage)
    {
        let attachment:NSTextAttachment = NSTextAttachment()
        attachment.image = image

        let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
        let myString:NSMutableAttributedString = NSMutableAttributedString(string: "")
        myString.append(attachmentString)
        myString.append(NSAttributedString(string: self.text!))

        self.attributedText = myString
    }
    
   
    func setProperties(textKey: String,fontsize: CGFloat,weight: UIFont.FontWeight, fontcolor: UInt)
    {
        
        self.text = getString(key: textKey)
        setProperties(fontsize: fontsize, weight: weight, fontcolor: fontcolor)
    }
    
    func setProperties(textKey: String,fontsize: CGFloat,weight: UIFont.FontWeight, textColor: UIColor)
    {
        self.text = getString(key: textKey)
        self.font = UIFont.systemFont(ofSize: fontsize, Weight: weight)
        self.textColor = textColor
    }
    
    func setProperties(fontsize: CGFloat,weight: UIFont.FontWeight, fontcolor: UInt)
    {
        
        self.font = UIFont.systemFont(ofSize: fontsize, Weight: weight)
        setTextColor(fontcolor: fontcolor)
    }
    
    func setText(key: String){
        self.text = getString(key: key)
    }
    
    func setText(key: String, with arguments: [CVarArg]) {
        self.text = getString(key: key, with: arguments)
    }
    
    func setTextColor(fontcolor: UInt) {
        self.textColor = UIColorFromRGB(rgbValueWithAlpha: fontcolor)
    }
    
    func makeMandatory() {
        
        if self.text?.hasSuffix("*") != true {
            
        
            let attrs1 = [NSAttributedString.Key.font : self.font, NSAttributedString.Key.foregroundColor : self.textColor]

            let attrs2 = [NSAttributedString.Key.font : self.font, NSAttributedString.Key.foregroundColor : UIColorFromRGB(rgbValueWithAlpha: MANDATORY_COLOR)]

            let attributedString1 = NSMutableAttributedString(string:self.text ?? "", attributes:attrs1 as [NSAttributedString.Key : Any])

            let attributedString2 = NSMutableAttributedString(string:" *", attributes:attrs2 as [NSAttributedString.Key : Any])

            attributedString1.append(attributedString2)
            self.attributedText = attributedString1
        }
    }
}

extension DateFormatter {
    static var dateFormater: DateFormatter = {
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "en")
        dateFormater.timeZone = TimeZone.autoupdatingCurrent
        return dateFormater
    }()
}

extension Date {
    
    static func dates(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = fromDate
        
        while date.startOfDay <= toDate.startOfDay {
            dates.append(date)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }
    
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
            return calendar.component(component, from: self)
    }
    
    func isSameDate(date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs:date)
    }
    
    var weekday: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: self)
        return components.weekday ?? 0
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func add(hours: Int) -> Date{
        var components = DateComponents()
        components.hour = hours
        return Calendar.current.date(byAdding: components, to: self)!
    }
    
    func add(days: Int) -> Date{
        var components = DateComponents()
        components.day = days
        return Calendar.current.date(byAdding: components, to: self)!
    }
    
    func add(months: Int) -> Date{
        var components = DateComponents()
        components.month = months
        return Calendar.current.date(byAdding: components, to: self)!
    }
    
    func minus(days: Int) -> Date{
        var components = DateComponents()
        components.day = -days
        return Calendar.current.date(byAdding: components, to: self)!
    }
    
    func minus(months: Int) -> Date{
        var components = DateComponents()
        components.month = -months
        return Calendar.current.date(byAdding: components, to: self)!
    }
    func minus(years: Int) -> Date{
        var components = DateComponents()
        components.year = -years
        return Calendar.current.date(byAdding: components, to: self)!
    }
    
    func isTomorrow() -> Bool{
        let calendar = Calendar.current
        return calendar.isDateInTomorrow(self)
    }
    var startOfMonth: Date {

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)

        return  calendar.date(from: components)!
    }
    
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
           return calendar.date(from: components)!
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    
    func isAfterOrEqual(date: Date) -> Bool {
        self >= date
    }
    func isBeforeEqual(date: Date) -> Bool {
        self <= date
    }
    
    func isAfter(date: Date) -> Bool {
        self > date
    }
    func isBefore(date: Date) -> Bool {
        self < date
    }
    
    func isEqual(date: Date) -> Bool {
        self == date
    }
    
    func getMinutesBetween(date: Date)-> Int {
        let newDateMinutes = date.timeIntervalSinceReferenceDate/60
        let oldDateMinutes = self.timeIntervalSinceReferenceDate/60

        return Int(newDateMinutes - oldDateMinutes)
    }
    
    static func getDateFromString(dateFormat: String, dateString: String) -> Date? {
        let dateFormatter = DateFormatter.dateFormater
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: dateString)
    }
    
    func getStringFromDate(dateFormat : String) -> String {
        let dateFormatter = DateFormatter.dateFormater
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
    
    func getDateObj(utcString: String?) -> Date?{
        
        if let utcString, let timestampMillis = Double(utcString) {
            
            let timestampSeconds = timestampMillis / 1000.0
            return Date(timeIntervalSince1970: timestampSeconds)
        }
        return nil
    }
    
    var isCurrentYear: Bool {
           return Calendar.current.component(.year, from: self) == Calendar.current.component(.year, from: Date())
       }
    
    func convertToAppTimezone() -> Date {
        let appTimeZone = TimeZone.current
        let offsetSeconds = appTimeZone.secondsFromGMT(for: self)
        return self.addingTimeInterval(TimeInterval(offsetSeconds))
    }
}

enum CardSize  {
    case LARGE
    case MEDIUM
    case SMALL
    case PILL
    
    var value: CGFloat {
        let base: CGFloat = {
            switch self {
            case .LARGE: return 12
            case .MEDIUM: return 12
            case .SMALL: return 12
            case .PILL: return 6
            }
        }()
        
        if #available(iOS 26.0, *) {
            return base
        } else {
            return base / 2
        }
    }
    
    func getPillSize(height: CGFloat) -> CGFloat {
        if #available(iOS 26.0, *) {
            return height / 2
        }
        else{
            return value
        }
        
    }
}

extension UIView
{
    func addCornerRadius(_ size: CardSize){
        layer.cornerRadius = size.value
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
    }
    
    
    func addPillCornerRadiusAndShadow(height: CGFloat, shadowOffset: CGSize? = nil){
        layer.shadowColor = UIColorFromRGB(rgbValueWithAlpha: SHADOW_COLOR).cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = shadowOffset ?? .init(width: 0, height: 2)
        layer.shadowRadius = 5
        layer.cornerRadius = CardSize.PILL.getPillSize(height: height)
        layer.cornerCurve = .continuous
        layer.masksToBounds = false
    }
    
    func addShadowAndCornerRadius(_ size: CardSize, shadowOffset: CGSize? = nil){
        layer.shadowColor = UIColorFromRGB(rgbValueWithAlpha: SHADOW_COLOR).cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = shadowOffset ?? .init(width: 0, height: 2)
        layer.shadowRadius = 5
        layer.cornerRadius = size.value
        layer.cornerCurve = .continuous
        layer.masksToBounds = false
        backgroundColor = .white
    }
    
    func addShadow(shadowOpacity: Float = 0.1, shadowOffset: CGSize? = nil){
        layer.shadowColor = UIColorFromRGB(rgbValueWithAlpha: SHADOW_COLOR).cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset ?? .init(width: 0, height: 2)
        layer.shadowRadius = 5
        layer.masksToBounds = false
    }
    
    func removeShadowAndCornerRadius(){
        layer.shadowColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_FOREGROUND_COLOR).cgColor
        layer.shadowOpacity = 0
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 0
        layer.cornerRadius = 0
        layer.masksToBounds = false
        backgroundColor = .clear
    }
    
    func setBackgroundColor(bgColor: UInt) {
        backgroundColor = UIColorFromRGB(rgbValueWithAlpha: bgColor)
    }
    
    func setLayerBackgroundColor(bgColor: UInt) {
        layer.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: bgColor).cgColor
    }
    
    func showView(){
        isHidden = false
    }
    
    func hideView() {
        isHidden = true
    }
    
}

extension UIView{
    func arrangeViews(constant: CGFloat, hasSpace: Bool, beforeView: UIView?){
        
        if hasSpace{
            if let beforeView = beforeView{
                self.setLeftRelatedToView(offSet: constant, relatedView: beforeView, relatedAttribute: .right)
                self.setTopRelatedToView(offSet: 0, relatedView: beforeView, relatedAttribute: .top)
            }
        }
        else{
            self.setLeft(offSet: 0)
            
            if let beforeView = beforeView{
                self.setTopRelatedToView(offSet: constant, relatedView: beforeView, relatedAttribute: .bottom)
            }
            else{
                self.setTop(offSet: 0)
            }
        }
    }
}
extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}

extension UIButton
{
    func setProperties(titleStrKey: String,fontsize: CGFloat,weight: UIFont.FontWeight, fontcolor: UInt, bgcolor: UInt? = nil )
    {
        
        self.setTitle(getString(key: titleStrKey), for: .normal)
        self.setTitleColor(UIColorFromRGB(rgbValueWithAlpha: fontcolor) , for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: fontsize, Weight: weight)
        
        if(bgcolor != nil){
            self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: bgcolor!)
        }
    }
    
    func setProperties(titleStrKey: String,fontsize: CGFloat,weight: UIFont.FontWeight, fontcolor: UIColor, bgcolor: UInt? = nil )
    {
        
        self.setTitle(getString(key: titleStrKey), for: .normal)
        self.setTitleColor(fontcolor, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: fontsize, Weight: weight)
        
        if(bgcolor != nil){
            self.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: bgcolor!)
        }
        
    }
    
    func setPadding(vertical: CGFloat, horizontal: CGFloat){
        var config = self.configuration ?? UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
    
    func setCustomPadding(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat){
        var config = self.configuration ?? UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

extension UITextField{
    
    func setPadding(width: Int , height: Int = 0) {
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        self.leftViewMode = .always
        self.rightView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        self.rightViewMode = .always
    }
}

extension NSMutableData
{
    func appendString(string: String)
    {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}


func getString(key: String, with arguments: [CVarArg]) -> String {
    return String(format: getString(key: key), arguments: arguments)
}

func getString(key: String) -> String {
    NSLocalizedString(key, comment: "")
}

extension UIImage {
    func fixedOrientation() -> UIImage {
        
        if self.imageOrientation == .up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalized ?? self
    }
    
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        let scaleFactor = min(widthRatio, heightRatio)

        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        return scaledImage
    }
}

extension UIButton {
    func setInsets(
        forContentPadding contentPadding: UIEdgeInsets? = nil,
        imageTitlePadding: CGFloat
    ) {
        self.contentEdgeInsets = UIEdgeInsets(
            top: contentPadding?.top ?? 0,
            left: contentPadding?.left ?? 0,
            bottom: contentPadding?.bottom ?? 0,
            right: contentPadding?.right ?? 0 + imageTitlePadding
        )
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: imageTitlePadding,
            bottom: 0,
            right: -imageTitlePadding
        )
    }
}

extension Date {
    var millisecondsSince1970:Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    var age: Int{
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: self, to: Date())
        return ageComponents.year ?? 0
    }
    
}


class FileUtil {
    
    static func createTempFile(data: Data,fileName: String, toCompress: Bool = true) -> URL? {
        
            
            debugPrintLog("file Name: \(fileName)")
        debugPrintLog("file size: \(data.count ) bytes")
//
            if toCompress {
                if let image = UIImage(data: data as Data) {
                    if let metaRemoved = image.jpegData(compressionQuality: 0.8) {
                        return FileUtil.insertTempFile(fileUrl: nil, tempFileName: fileName, data: metaRemoved as NSData)
                    }
                }
                else{
                    return FileUtil.insertTempFile(fileUrl: nil, tempFileName: fileName, data: data as NSData)
                }
            }
            else{
                return FileUtil.insertTempFile(fileUrl: nil, tempFileName: fileName, data: data as NSData)
            }
        
        
        return nil
    }
    
    
    static func createTempFile(fileUrl: URL , tempFileName: String? = nil , toCompress: Bool = true) -> URL? {
        
        if let data = NSData(contentsOf: fileUrl){
            
//            debugPrintLog("file Name: \(fileUrl.pathComponents.last ?? "")")
//            debugPrintLog("file size: \(data.count ?? 0) bytes")
//
            if toCompress {
                if let image = UIImage(data: data as Data) {
                    if let metaRemoved = image.jpegData(compressionQuality: 0.8) {
                        return FileUtil.insertTempFile(fileUrl: fileUrl, tempFileName: tempFileName, data: metaRemoved as NSData)
                    }
                }
                else{
                    return FileUtil.insertTempFile(fileUrl: fileUrl, tempFileName: tempFileName, data: data)
                }
            }
            else{
                return FileUtil.insertTempFile(fileUrl: fileUrl, tempFileName: tempFileName, data: data)
            }
        }
        
        return nil
    }
    private static func insertTempFile(fileUrl: URL?, tempFileName: String? , data: NSData?) -> URL?{
        
        do {
            debugPrintLog("file Name: \(fileUrl?.pathComponents.last ?? "")")
           debugPrintLog("file size: \(data?.count ?? 0) bytes")

             let tempLocation = FileManager.default.temporaryDirectory
            
            let directory: URL
            
            if #available(iOS 16.0, *){
                directory = tempLocation.appending(path: "mPHRDoc", directoryHint: .isDirectory)
            }
            else{
                directory = tempLocation.appendingPathComponent("mPHRDoc")
            }
            if !FileManager.default.fileExists(atPath: directory.path) {
                try FileManager.default.createDirectory(atPath: directory.path, withIntermediateDirectories: true, attributes: nil)
            }
            
            var pathComponent = "\(fileUrl?.pathComponents.last ?? tempFileName ?? "")"
            
            if pathComponent.isBlank() {
                return nil
            }
            
            let localURL = directory.appendingPathComponent(pathComponent)
            
            try data?.write(to: localURL)
            debugPrintLog("file created successfully")
            debugPrintLog("MimeType -> \(localURL.mimeType())")
            return localURL
            
        }
        catch {
            debugPrintLog("FILE_ERROR -> \(error.localizedDescription)")
        }
        return nil
    }
    
    static func removeTempFile(fileUrl: URL){
        
        do {
            try FileManager.default.removeItem(at: fileUrl)
         //   debugPrintLog("file deleted successfully")
            
        }
        catch {
           // debugPrintLog("FILE_ERROR -> \(error.localizedDescription)")
        }
    }
    
    static func removeAllTempFile(){
        
        do {
            let directory = FileManager.default.temporaryDirectory

            let mphrDoc = directory.appendingPathComponent("mPHRDoc")
            
            let docList = try FileManager.default.contentsOfDirectory(at:mphrDoc , includingPropertiesForKeys: nil , options: .skipsHiddenFiles)

            try docList.forEach({fileUrl in
                
              //  debugPrintLog("mPHR file Name: \(fileUrl.pathComponents.last ?? "")")
                try FileManager.default.removeItem(at: fileUrl)

            })
        }
        catch {
            //debugPrintLog("FILE_ERROR -> \(error.localizedDescription)")
        }
    }
    
}


extension URL {
    public func mimeType() -> String {
        if let mimeType = UTType(filenameExtension: self.pathExtension)?.preferredMIMEType {
            return mimeType
        }
        else {
            return "application/octet-stream"
        }
    }
}

extension Data {
    
    func aes256Encrypt(withKey key: String) -> Data? {
        let keySize = kCCKeySizeAES256
        var keyPtr = [UInt8](repeating: 0, count: keySize)
        
        if let keyData = key.data(using: .utf8) {
            keyData.copyBytes(to: &keyPtr, count: Swift.min(keyData.count, keySize))
        }
        
        let dataLength = self.count
        let bufferSize = dataLength + kCCBlockSizeAES128
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        var numBytesEncrypted: size_t = 0
        
        let cryptStatus = self.withUnsafeBytes { dataBytes in
            CCCrypt(CCOperation(kCCEncrypt),
                    CCAlgorithm(kCCAlgorithmAES128),
                    CCOptions(kCCOptionPKCS7Padding),
                    keyPtr, kCCKeySizeAES256,
                    nil, // IV
                    dataBytes.baseAddress, dataLength,
                    &buffer, bufferSize,
                    &numBytesEncrypted)
        }
        
        if cryptStatus == kCCSuccess {
            return Data(bytes: buffer, count: numBytesEncrypted)
        } else {
            return nil
        }
    }
    
    func aes256Decrypt(withKey key: String) -> Data? {
        // Ensure the key is 32 bytes (256 bits) for AES256
        var keyPtr = [UInt8](repeating: 0, count: kCCKeySizeAES256)
        if let keyData = key.data(using: .utf8) {
            keyData.copyBytes(to: &keyPtr, count: Swift.min(keyData.count, kCCKeySizeAES256))
        }
        
        let dataLength = self.count
        let bufferSize = dataLength + kCCBlockSizeAES128
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        var numBytesDecrypted: size_t = 0
        
        let cryptStatus = self.withUnsafeBytes { dataBytes in
            buffer.withUnsafeMutableBytes { bufferBytes in
                CCCrypt(
                    CCOperation(kCCDecrypt),
                    CCAlgorithm(kCCAlgorithmAES),
                    CCOptions(kCCOptionPKCS7Padding),
                    keyPtr,
                    kCCKeySizeAES256,
                    nil, // IV (Initialization Vector) can be added if needed
                    dataBytes.baseAddress,
                    dataLength,
                    bufferBytes.baseAddress,
                    bufferSize,
                    &numBytesDecrypted
                )
            }
        }
        
        if cryptStatus == kCCSuccess {
            return Data(bytes: buffer, count: numBytesDecrypted)
        } else {
            // Handle the decryption error
            debugPrintLog("Error during decryption: \(cryptStatus)")
            return nil
        }
    }
}

extension UISegmentedControl{
    func addBlurEffect(_ effectStyle: UIBlurEffect.Style = .systemMaterial) {
        let blurEffect = UIBlurEffect(style: effectStyle)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.insertSubview(blurView, at: 0)
    }
    
    func addProperties(fontSize: CGFloat){
        setTitleTextAttributes([.foregroundColor: UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR),.font:UIFont.systemFont(ofSize: fontSize, weight: .semibold)], for: .selected)
        setTitleTextAttributes([.foregroundColor:UIColorFromRGB(rgbValueWithAlpha: TEXT_COLOR_BLACK87),.font:UIFont.systemFont(ofSize: fontSize, weight: .semibold)], for: .normal)
        selectedSegmentTintColor = .white
        layer.cornerRadius = SEGMENTCONTROL_HEIGHT / 2
    }
}

func debugPrintLog(_ message: Any) {
    #if DEBUG
    debugPrint(message)
    #endif
}

class VitalUtil {
    
    static func getPatientVitalUnit(selectedPatientId: String? = nil) -> String? {
        
        let patientId = selectedPatientId ?? getSelectedPatientId()
        
        let standardVitalUnitDefault = StandardUserDefaults.object(forKey: isStandardVitalUnitKey)  as? [String : Bool] ?? [:]

        if let isStandard = standardVitalUnitDefault.getBoolean(patientId) {
            
            if isStandard {
                return vitalUnitStandard
            }
            else{
                return vitalUnitMetric
            }
        }
        return nil
    }
    
    static func savePatientVitalUnit(vitalUnit:String, selectedPatientId: String? = nil) {
        
        let patientId = selectedPatientId ?? getSelectedPatientId()
        
        var standardVitalUnitDefault = StandardUserDefaults.object(forKey: isStandardVitalUnitKey)  as? [String : Bool] ?? [:]
        
        if vitalUnit == vitalUnitStandard{
            standardVitalUnitDefault.addProperty(patientId, true)
        }
        else{
            standardVitalUnitDefault.addProperty(patientId, false)
        }
        
        StandardUserDefaults.set(standardVitalUnitDefault, forKey: isStandardVitalUnitKey)
        StandardUserDefaults.synchronize()
        
        
    }
}


class MDPaginationHandler <Element: DateDelegate> {
    private let moduleId: String

    private var practiceList:[String] = []
    private var itemList:[Element] = []
    var count = 20
    init(moduleId: String) {
        self.moduleId = moduleId
        practiceList = getEnabledPractices(moduleId: moduleId)
    }
    
    func updatePaginationResponse(pagination: MDPagiationDataResponse<Element>) {
        //updates the response
        let dataList = pagination.data ?? []
        debugPrintLog("MDPagination: Data got added: \(dataList.count)")
        debugPrintLog("MDPagination: From Practice: \(practiceList.count)")
        itemList.append(contentsOf: pagination.data ?? [])
        itemList.sort(by: { (item1, item2) -> Bool in
            
            let dateObj1 = item1.getDate()
            let dateObj2 = item2.getDate()
            return dateObj1 > dateObj2
        })
        debugPrintLog("MDPagination: Full Count: \(itemList.count)")

        
        let hasMoreDict =  pagination.hasMore
        practiceList = hasMoreDict.filter({key , value in
            return value
        }).map({key , value in
            return key
        })
    }
    
    func getNextElements() -> [Element] {
        
        var removedList:[Element] = []
        if itemList.count > count {
            debugPrintLog("MDPagination: Next Element: \(count)")
            removedList = itemList.removeFirst(count: count)
        }
        else if itemList.isEmpty {
            debugPrintLog("MDPagination: No Element")
            
        }
        else {
            debugPrintLog("MDPagination: Next Element: \(itemList.count)")
            removedList = itemList.removeFirst(count: itemList.count)
        }
        
        debugPrintLog("MDPagination: Full Count: \(itemList.count)")
        
        return removedList
        // gives the next set to view
    }
    
    func getPracticeIdHasData(isFirst: Bool = false) -> [String] {// RETURNS practice list that has to be fetched.
        // to fetch data for these practice
        
        
        if isFirst {
            practiceList = getEnabledPractices(moduleId: moduleId)
        }
        
        debugPrintLog("MDPagination: Available Practice : \(practiceList.count)")
        return practiceList
    }
    
    func allowInfinityScroll() -> Bool {
        debugPrintLog("MDPagination: Allow Pagination : \(!practiceList.isEmpty || !itemList.isEmpty)")
        debugPrintLog("MDPagination---------------------------------------------------------------------------")
        return !practiceList.isEmpty || !itemList.isEmpty
    }
}

protocol DateDelegate {
    func getDate() -> Date
}

import UIKit
import ObjectiveC

private struct AssociatedKeys {
    static var maxLengthKey: UInt8 = 0
    static var placeholderKey: UInt8 = 0
    static var placeholderLabelKey: UInt8 = 0
}

extension UITextView {

    // MARK: - Max Length
    @IBInspectable var maxLength: Int {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.maxLengthKey) as? Int ?? Int.max
        }
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.maxLengthKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            startObservingChanges()
        }
    }

    // MARK: - Placeholder
    @IBInspectable var placeholder: String? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.placeholderKey) as? String
        }
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.placeholderKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            setupPlaceholderLabel()
            startObservingChanges()
        }
    }

    // MARK: - Placeholder Label
    private var placeholderLabel: UILabel {
        if let label = objc_getAssociatedObject(self, &AssociatedKeys.placeholderLabelKey) as? UILabel {
            return label
        }

        let label = UILabel()
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.font = self.font
        label.translatesAutoresizingMaskIntoConstraints = false

        objc_setAssociatedObject(self,
                                 &AssociatedKeys.placeholderLabelKey,
                                 label,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return label
    }

    private func setupPlaceholderLabel() {
        if placeholderLabel.superview == nil {
            addSubview(placeholderLabel)

            NSLayoutConstraint.activate([
                placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 6),
                placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
                placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4)
            ])
        }

        placeholderLabel.text = placeholder
        placeholderLabel.isHidden = !text.isEmpty
    }

    // MARK: - Observe Changes (NO delegate conflicts)
    private func startObservingChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChangeNotification),
            name: UITextView.textDidChangeNotification,
            object: self
        )
    }

    // MARK: - Core Logic (placeholder + maxLength)
    @objc private func textDidChangeNotification() {

        // Placeholder visibility
        placeholderLabel.isHidden = !self.text.isEmpty

        // Max length
        if self.text.count > maxLength {
            let selectedRange = self.selectedRange
            self.text = String(self.text.prefix(maxLength))
            self.selectedRange = selectedRange
        }
    }
}

extension UITextField {
    
    @IBInspectable var maxLength: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.maxLengthKey) as? Int ?? Int.max
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.maxLengthKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            addTarget(self, action: #selector(limitLength), for: .editingChanged)
        }
    }
    
    @objc private func limitLength(textField: UITextField) {
        guard let prospectiveText = textField.text,
              prospectiveText.count > maxLength else {
            return
        }
        
        let selection = selectedTextRange
        text = String(prospectiveText.prefix(maxLength))
        selectedTextRange = selection
    }
}
