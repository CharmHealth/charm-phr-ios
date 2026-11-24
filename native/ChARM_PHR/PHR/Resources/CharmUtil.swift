//
//  CharmUtil.swift
//  phr
//
//  Created by Sankar Saravanan on 18/05/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import SwiftUI

struct CharmUtil {
        
//MARK: - Generate RandomKey
    
    static func generateRandomKey(length: Int) -> String{
        
        var hasError: Bool = false
        var data = Data(count: length)
        
        data.withUnsafeMutableBytes { bytes in
            let result = SecRandomCopyBytes(kSecRandomDefault, length, bytes.baseAddress!)
            if result != errSecSuccess {
                debugPrintLog("Error generating random bytes: \(result)")
                hasError = true
            }
        }
        if hasError{
            return randomString(length: length)
        }
        else{
            return data.base64EncodedString()
        }
    }
    
    private static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    static func getAlertAction(title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)?) -> UIAlertAction{
        let alertAction = UIAlertAction(title: title, style: style, handler: handler)
        if style == .destructive{
            alertAction.setValue(UIColor.systemRed, forKey: "titleTextColor")
        }
        else{
            alertAction.setValue(UIColorFromRGB(rgbValueWithAlpha: THEME_COLOR), forKey: "titleTextColor")
        }
        return alertAction
    }
    
//MARK: - Show Toast
    
    static func showToast(controller: UIViewController?, message: String?, seconds: Double) {
        
        guard let controller else { return }
        
        let toastView = AnyView(
            EmptyView()
                .showToast(isShowing: .constant(true), message: message ?? "", duration: seconds)
        )
        
        // Host SwiftUI inside UIKit
        let hosting = UIHostingController(rootView: toastView)
        hosting.view.backgroundColor = .clear
        
        controller.addChild(hosting)
        controller.view.addSubview(hosting.view)
        hosting.didMove(toParent: controller)
        
        // Make overlay cover full screen (like SwiftUI ZStack)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: controller.view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor)
        ])
        
        // Remove after toast duration
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds + 0.5) {
            hosting.willMove(toParent: nil)
            hosting.view.removeFromSuperview()
            hosting.removeFromParent()
        }
    }
    
//    static func showToast(controller: UIViewController?, message: String?, seconds: Double){
//        let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
//        controller?.present(alert, animated: true)
//        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds, execute: {
//            alert.dismiss(animated: true)
//        })
//    }
    
//MARK: - Create Alert functions
    
    static func createOkayAlertWith(error: Error, errorDescription: String = getString(key: "com.charmphr.alertError"), alertViewPriority: AlertViewPriority = AlertViewPriorityMedium)
    {
        let errorCode = (error as NSError).code
        debugPrintLog(errorCode)
        debugPrintLog(error.localizedDescription)
        
        let errorMsg = getErrorMsg(error: error)
        
        let alertVC = UIAlertController(title: nil, message: errorMsg.isBlank() ? errorDescription : errorMsg, preferredStyle: .alert)
        
        alertVC.alertViewPriority =  alertViewPriority
        
        let okAction = getAlertAction(title: getString(key: "com.charmphr.action.Ok"), style: .default, handler: { (UIAlertAction) in
        })
        alertVC.addAction(okAction)
        alertVC.show()
    }
    
    static func createOkayAlertWith(error: Error, errorDescription: String = getString(key: "com.charmphr.alertError"), okClicked: @escaping () -> Void)
    {
        let errorCode = (error as NSError).code
        debugPrintLog(errorCode)
        debugPrintLog(error.localizedDescription)
        
        let errorMsg = getErrorMsg(error: error)
        
        let alertVC = UIAlertController(title: nil, message: errorMsg.isBlank() ? errorDescription : errorMsg, preferredStyle: .alert)

        alertVC.alertViewPriority =  AlertViewPriorityMedium
        let okAction = getAlertAction(title: getString(key: "com.charmphr.action.Ok"), style: .default, handler: { (UIAlertAction) in
            okClicked()
        })
        alertVC.addAction(okAction)
        alertVC.show()
    }
    
    static func createRetryAndCancelAlertWith(error: Error, errorDescription : String = getString(key: "com.charmphr.alertError"), tryAgainClicked: @escaping () -> Void)
    {
        let errorCode = (error as NSError).code
        debugPrintLog(errorCode)
        debugPrintLog(error.localizedDescription)
        
        let errorMsg = getErrorMsg(error: error)
        
        let alertVC = UIAlertController(title: nil, message: errorMsg.isBlank() ? errorDescription : errorMsg, preferredStyle: .alert)
        
        alertVC.alertViewPriority =  AlertViewPriorityMedium
        let retryAction = getAlertAction(title: getString(key: "com.charmphr.action.retry"), style: .default, handler: { (UIAlertAction) in
            tryAgainClicked()
        })
        alertVC.addAction(retryAction)
        
        let cancelAction = getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .cancel, handler: { (UIAlertAction) in

        })
        alertVC.addAction(cancelAction)
    
        alertVC.show()
    }
    
    static func createRetryAndCancelAlertWith(error: Error, errorDescription : String = getString(key: "com.charmphr.alertError"), alertViewPriority: AlertViewPriority = AlertViewPriorityMedium, tryAgainClicked: @escaping () -> Void, cancelClicked: @escaping () -> Void)
    {
        let errorCode = (error as NSError).code
        debugPrintLog(errorCode)
        debugPrintLog(error.localizedDescription)
        
        let errorMsg = getErrorMsg(error: error)
        
        let alertVC = UIAlertController(title: nil, message: errorMsg.isBlank() ? errorDescription : errorMsg, preferredStyle: .alert)
        
        alertVC.alertViewPriority =  alertViewPriority
        let retryAction = getAlertAction(title: getString(key: "com.charmphr.action.retry"), style: .default, handler: { (UIAlertAction) in
            tryAgainClicked()
        })
        alertVC.addAction(retryAction)
        
        let cancelAction = getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .cancel, handler: { (UIAlertAction) in
            cancelClicked()
        })
        alertVC.addAction(cancelAction)
        alertVC.show()
    }
    
    static func createOkayAlertWith(title: String?, msg : String?)
    {
        let alertVC = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertVC.alertViewPriority =  AlertViewPriorityMedium
        let okAction = getAlertAction(title: getString(key: "com.charmphr.action.Ok"), style: .default, handler: { (UIAlertAction) in
            
        })
        alertVC.addAction(okAction)
        alertVC.show()
    }
    
    static func createOkayAlertWith(title: String?, msg: String?, okClicked: @escaping () -> Void)
    {
        let alertVC = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertVC.alertViewPriority =  AlertViewPriorityMedium
        let okAction = getAlertAction(title: getString(key: "com.charmphr.action.Ok"), style: .default, handler: { (UIAlertAction) in
            okClicked()
        })
        alertVC.addAction(okAction)
        alertVC.show()
    }
    
    static func createOkayWithCancelAlertWith(title: String?, msg: String?, okClicked: @escaping () -> Void , okString: String = "com.charmphr.action.Ok")
    {
        let alertVC = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertVC.alertViewPriority =  AlertViewPriorityMedium
        let okAction = getAlertAction(title: getString(key: okString), style: .default, handler: { (UIAlertAction) in
            okClicked()
        })
        alertVC.addAction(okAction)
        
        let cancelAction = getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .default, handler: { (UIAlertAction) in
            
        })
        alertVC.addAction(cancelAction)
        
        alertVC.show()
    }
    
    static func createRetryAndCancelAlertWith(title: String?, msg: String?, tryAgainClicked: @escaping () -> Void)
    {
        let alertVC = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertVC.alertViewPriority =  AlertViewPriorityMedium
        let retryAction = getAlertAction(title: getString(key: "com.charmphr.action.retry"), style: .default, handler: { (UIAlertAction) in
            tryAgainClicked()
        })
        alertVC.addAction(retryAction)
        let cancelAction = getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .cancel, handler: { (UIAlertAction) in

        })
        alertVC.addAction(cancelAction)
        alertVC.show()
    }
    
    static func createRetryAndCancelAlertWith(title: String, msg: String?, tryAgainClicked: @escaping () -> Void ,cancelClicked: @escaping () -> Void)
    {
        let alertVC = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertVC.alertViewPriority =  AlertViewPriorityMedium
        let retryAction = getAlertAction(title: getString(key: "com.charmphr.action.retry"), style: .default, handler: { (UIAlertAction) in
            tryAgainClicked()
        })
        alertVC.addAction(retryAction)
        let cancelAction = getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .cancel, handler: { (UIAlertAction) in
            cancelClicked()
        })
        alertVC.addAction(cancelAction)
        alertVC.show()
    }
    
    static func createDeleteAndCancelAlertWith(title: String?, msg: String?, deleteClicked: @escaping () -> Void)
    {
        let alertVC = UIAlertController(title: title, message: msg, preferredStyle: .actionSheet)
        alertVC.alertViewPriority =  AlertViewPriorityMedium
        let deleteAction = getAlertAction(title: getString(key: "com.charmphr.action.delete"), style: .destructive, handler: { (UIAlertAction) in
            deleteClicked()
        })
        alertVC.addAction(deleteAction)
        let cancelAction = getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .cancel, handler: { (UIAlertAction) in
        })
        alertVC.addAction(cancelAction)
        alertVC.show()
    }
    
    static func createYesOrNoActionWith(title: String?, msg: String?, yesClicked: @escaping () -> Void)
    {
        let alertVC = UIAlertController(title: title, message: msg, preferredStyle: .actionSheet)
        alertVC.alertViewPriority =  AlertViewPriorityMedium
        let deleteAction = getAlertAction(title: getString(key: "com.charmphr.common.yes"), style: .destructive, handler: { (UIAlertAction) in
            yesClicked()
        })
        alertVC.addAction(deleteAction)
        let cancelAction = getAlertAction(title: getString(key: "com.charmphr.common.no"), style: .cancel, handler: { (UIAlertAction) in
        })
        alertVC.addAction(cancelAction)
        alertVC.show()
    }
    
    static func createYesAndNoAlertWith(title: String?, msg: String?, yesClicked: @escaping () -> Void ,noClicked: @escaping () -> Void)
    {
        let alertVC = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertVC.alertViewPriority =  AlertViewPriorityMedium
        
        let noAction = getAlertAction(title: getString(key: "com.charmphr.common.no"), style: .default, handler: { (UIAlertAction) in
            noClicked()
        })
        alertVC.addAction(noAction)
        let yesAction = getAlertAction(title: getString(key: "com.charmphr.common.yes"), style: .default, handler: { (UIAlertAction) in
            yesClicked()
        })
        alertVC.addAction(yesAction)
        alertVC.show()
    }
    
    static func createYesAndNoAlertWith(title: String?, msg: String?, yesClicked: @escaping () -> Void)
    {
        let alertVC = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertVC.alertViewPriority =  AlertViewPriorityMedium
        let noAction = getAlertAction(title: getString(key: "com.charmphr.common.no"), style: .default, handler: { (UIAlertAction) in
        })
        alertVC.addAction(noAction)
        let yesAction = getAlertAction(title: getString(key: "com.charmphr.common.yes"), style: .default, handler: { (UIAlertAction) in
            yesClicked()
        })
        alertVC.addAction(yesAction)
        alertVC.show()
    }
    
    
    static func createOkAndCancelAlertWith(title: String?, msg: String?, okClicked: @escaping () -> Void)
    {
        let alertVC = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertVC.alertViewPriority =  AlertViewPriorityMedium
        
        let cancelAction = getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .cancel, handler: { (UIAlertAction) in
        })
        alertVC.addAction(cancelAction)
        let okAction = getAlertAction(title: getString(key: "com.charmphr.action.Ok"), style: .default, handler: { (UIAlertAction) in
            okClicked()
        })
        alertVC.addAction(okAction)
        alertVC.show()
    }
    
    static func createCancelAndSettingsAlertWith(title: String?, msg: String?, settingsClicked: @escaping () -> Void, cancelClicked: @escaping () -> Void)
    {
        let alertVC = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertVC.alertViewPriority =  AlertViewPriorityMedium
        
        let cancelAction = getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .cancel, handler: { (UIAlertAction) in
            cancelClicked()
        })
        alertVC.addAction(cancelAction)
        let settingAction = getAlertAction(title: getString(key: "com.charmphr.action.settings"), style: .default, handler: { (UIAlertAction) in
            settingsClicked()
        })
        alertVC.addAction(settingAction)
        alertVC.show()
    }
    
    static func showDiscardChangesAlert(discardBtnAction: (() -> Void)?, barButtonItem: UIBarButtonItem?){
        
        var alertVC: UIAlertController? = nil
        
        if #available(iOS 26.0, *){
            alertVC = UIAlertController(title: nil, message: getString(key: "com.charmphr.common.discarded.alert.msg"), preferredStyle: .actionSheet)
        }
        else{
            alertVC = UIAlertController(title: nil, message: getString(key: "com.charmphr.common.discarded.alert.msg"), preferredStyle: .alert)
        }
        
        guard let alertVC else { return }
        alertVC.alertViewPriority =  AlertViewPriorityMedium
        
        let cancelAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .cancel, handler: nil)
        let discardAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.Discard"), style: .destructive, handler: { (UIAlertAction) in
            discardBtnAction?()
        })
        alertVC.addAction(cancelAction)
        alertVC.addAction(discardAction)
        
        if let popover = alertVC.popoverPresentationController {
            popover.barButtonItem = barButtonItem   // anchor to the button that triggered it
            popover.permittedArrowDirections = .up
        }
        alertVC.show(animated: true)
    }
    
    static func showPhotoOrDocumentSelectionAlert(barButton: UIBarButtonItem?, photoSelected: @escaping () -> Void, documentSelected: @escaping () -> Void){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let photoAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.message.compose.photoAndVideo"), style: .default) { (uialertaction) in
            photoSelected()
        }
        
        let documentAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.message.compose.Documents"), style: .default) { (uialertaction) in
            documentSelected()
        }
        
        let cancelAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .cancel, handler: nil)
        
        alertController.addAction(photoAction)
        alertController.addAction(documentAction)
        alertController.addAction(cancelAction)
        
        if let popover = alertController.popoverPresentationController {
            popover.barButtonItem = barButton
            popover.permittedArrowDirections = .up
        }
        
        alertController.show()
    }
    
    static func showCameraOrPhotoSelectionAlert(view: UIView?, barButton: UIBarButtonItem?, photoSelected: @escaping () -> Void, cameraSelected: @escaping () -> Void){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let photoAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.message.compose.photoAndVideo"), style: .default) { (uialertaction) in
            photoSelected()
        }
        
        let cameraAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.EditDemographics.camera.title"), style: .default) { (uialertaction) in
            cameraSelected()
        }
        
        let cancelAction = CharmUtil.getAlertAction(title: getString(key: "com.charmphr.action.cancel"), style: .cancel, handler: nil)
        
        alertController.addAction(photoAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        
        if let popover = alertController.popoverPresentationController {
            if let barButton{
                popover.barButtonItem = barButton
            }
            else if let view{
                popover.sourceView = view
            }
            popover.permittedArrowDirections = .up
        }
        
        alertController.show()
    }
    
//MARK: - Get Error Message
    
    static func getErrorMsg(error : Error) -> String
    {
        let nsError = error as NSError
        switch nsError.code {
        case 310: //Proxy error
            return getString(key: "com.charmphr.alertForTimeOut")
        case -1001:
            return getString(key: "com.charmphr.alertForTimeOut")
        case -1004:
            return getString(key: "com.charmphr.alertForServerDown")
        case -1009:
            return getString(key: "com.charmphr.alertForNoNetworkConnection")
        case -1020:
            return getString(key: "com.charmphr.alertForNoNetworkConnection")
        case -1012:
            return getString(key: "com.charmphr.alertForAuthendicationCancelled")
        case -1000:
            return getString(key: "com.charmphr.alertForInternalServer")
        case CUSTOM_ERROR_CODE:
            return nsError.domain
        default:
            if nsError.localizedDescription.isNotBlank() {
                return nsError.localizedDescription
            }
            else{
                return getString(key: "com.charmphr.alertError")
            }
        
        }
    }
    
    static func getCustomError(domainKey: String, userInfo: [String: Any]? = nil) -> Error{
        return NSError(domain: getString(key: domainKey), code: CUSTOM_ERROR_CODE, userInfo: userInfo)
    }
    
//MARK: - Date formatter related methods
    
    static func getDateStringWith(date:Date? , dateFormat : String)-> String
    {        
        if let date = date {
            return date.getStringFromDate(dateFormat: dateFormat)
        }
        else{
            return ""
        }
    }
    
    static func getDateObjectWith(dateString:String , dateFormat : String)-> Date?
    {
        if dateString.isBlank() {
            return nil
        }
        
        return Date.getDateFromString(dateFormat: dateFormat, dateString: dateString)
    }
    
    static func getDisplayDateString(date:Date,skipCurrentYear:Bool = true)-> String
    {
        
        let calender = Calendar(identifier: .gregorian)
        if (calender.isDate(Date(), equalTo: date, toGranularity: .year) && skipCurrentYear)
        {
            return CharmUtil.getDateStringWith(date: date, dateFormat:PHR_DATE_DISPLAY_FORMAT)
        }else
        {
            return CharmUtil.getDateStringWith(date: date, dateFormat:PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
        }
    }
    static func getDisplayDateStringWithYearAndTime(date:Date)-> String
    {
        return CharmUtil.getDateStringWith(date: date, dateFormat: FLOWSHEET_DATA_DATE_FORMAT)
        
    }
    
    static func getDisplayDateStringWithYear(date:Date)-> String
    {
        return CharmUtil.getDateStringWith(date: date, dateFormat:PHR_DATE_DISPLAY_FORMAT_WITH_YEAR)
    }
    
    static func getDisplayDateStringWithDay(date:Date)-> String
    {
        let calender = Calendar(identifier: .gregorian)
        if calender.isDate(Date(), equalTo: date, toGranularity: .year)
        {
            return CharmUtil.getDateStringWith(date: date, dateFormat:PHR_DATE_DISPLAY_FORMAT_WITH_DAY)
        }else
        {
            return CharmUtil.getDateStringWith(date: date, dateFormat:PHR_DATE_DISPLAY_FORMAT_WITH_DAY_YEAR)
        }
    }
    
    static func getDisplayDateStringAndToday(date : Date, showTimeForToday : Bool = false) -> String
    {
        let calender = Calendar(identifier: .gregorian)
        if calender.isDateInToday(date)
        {
            if showTimeForToday
            {
                let locale = NSLocale.current
                let formatter : String = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale:locale)!
                if formatter.contains("a") {
                    return CharmUtil.getDateStringWith(date: date, dateFormat: "h:mm a") // for 12hr format
                } else {
                    return CharmUtil.getDateStringWith(date: date, dateFormat: Time24HoursFormat) // for 24hr format
                }
            }else
            {
                return getString(key: "com.charmphr.common.today")
            }
        }
        else
        {
            return self.getDisplayDateStringWithDay(date: date)
        }
    }
    
    static func roundToTwo(value: Double) -> Double {
        return round(value * 100.00)/100.00
    }
    
    
    static func getHealthKitPreference() -> Patient? {
        
        let selectedPatientId = UserDefaults.standard.string(forKey: hkPreferenceKey)
        
        if !selectedPatientId.isNilOrBlank() {
            if let selectedPatient = Patient.patientList?.first(where: { $0.patientId == selectedPatientId }) {
                return selectedPatient
            }
        }
        return nil
    }
    
    static func saveHealthKitPreference(patient: Patient) {
        
        let standard = UserDefaults.standard
        standard.set(patient.patientId ?? "", forKey: hkPreferenceKey)
        standard.synchronize()
    }
    
    static func removeHealthKitPreference() {
        
        let standard = UserDefaults.standard
        standard.removeObject(forKey: hkPreferenceKey)
        standard.synchronize()
    }
    
    
    
    static func formattedRange(from startDate: Date,
                                  to endDate: Date) -> String {

           let calendar = Calendar.current

           let startYear = calendar.component(.year, from: startDate)
           let endYear = calendar.component(.year, from: endDate)

           let monthDayFormatter = DateFormatter()
           monthDayFormatter.dateFormat = "MMM d"

           let fullFormatter = DateFormatter()
           fullFormatter.dateFormat = "MMM d, yyyy"

           let endFormatter = DateFormatter()
           endFormatter.dateFormat = "MMM d, yyyy"

           // Same year
           if startYear == endYear {
               let startString = monthDayFormatter.string(from: startDate)
               let endString = endFormatter.string(from: endDate)
               return "\(startString) - \(endString)"
           }
           // Different years
           else {
               let startString = fullFormatter.string(from: startDate)
               let endString = endFormatter.string(from: endDate)
               return "\(startString) - \(endString)"
           }
       }
    
    
    // uncommend this if we need to use date string with today,yesterday,weekday
    /*
        if calender.isDate(Date(), equalTo: date, toGranularity: .year)
        {
//            if calender.isDate(Date(), equalTo: date, toGranularity: .month)
//            {
//                if calender.isDateInToday(date)
//                {
//                    return NSLocalizedString("com.charmphr.common.today", comment: "")
//                }
//                else if calender.isDateInYesterday(date)
//                {
//                    return NSLocalizedString("com.charmphr.common.yesterday", comment: "")
//                }
//                else if calender.isDate(Date(), equalTo: date, toGranularity: .weekOfYear)
//                {
//                    return CharmUtil.getDateStringWith(date: date, dateFormat: "EEEE")
//                }
//            }
            if calender.isDateInToday(date)
            {
                return CharmUtil.getDateStringWith(date: date, dateFormat: "dd MMMM")
            }
            return CharmUtil.getDateStringWith(date: date, dateFormat: "dd MMMM")
        }else
        {
            return CharmUtil.getDateStringWith(date: date, dateFormat: "dd MMMM yyyy")
        }
    */
}
