//
//  CancelAppointmentViewController.swift
//  phr
//
//  Created by Raghul D on 03/10/24.
//  Copyright © 2024 Dhanuprasanya P. All rights reserved.
//

import Foundation

class CancelAppointmentViewController: UIViewController , CharmConnectionV2HandlerDelegate {
   
    
    @objc lazy private var cancelAppointmentView: CancelAppointmentView = CancelAppointmentView(delegate: self)
    
    var appointment: Appointment? = nil
    var indexPath: IndexPath? = nil
    weak var delegate: CancelAppointmentViewControllerDelegate? = nil

    private var charmConnectionHandler: CharmConnectionHandler? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        charmConnectionHandler = CharmConnectionHandler(v2Delegate: self)
        self.view.addSubview(cancelAppointmentView)
        cancelAppointmentView.addConstraintPostViewLoad()
        self.view.setBackgroundColor(bgColor: PRESENT_VC_BG_COLOR)
    }
    
    
    func cancelAppointment(reason:String){
        
        if let appointment = appointment {
            cancelAppointmentView.showActivityIndicator()
            charmConnectionHandler?.cancelAppointment(appointment: appointment, reason: reason, identificationKey: "cancelAppointment")
        }
    }
    
    func dismissCancelVC(){
        delegate?.onAppointmentCancelled(indexPath: nil)
        self.dismiss(animated: true)
    }
    
    //MARK: - CharmConnection handler delegate
    func charmConnectionV2HandlerDidRecieve(response: Any, identificationKey: String) {
        if identificationKey == "cancelAppointment"{
            cancelAppointmentView.hideActivityIndicator()

            if response is Bool {
                if let indexPath = indexPath {
                    delegate?.onAppointmentCancelled(indexPath: indexPath)
                }
                self.dismiss(animated: true)
            }
        }
    }
    
    func charmConnectionV2HandlerDidFailWithError(error: Error, identificationKey: String) {
        if identificationKey == "cancelAppointment"{
            cancelAppointmentView.hideActivityIndicator()
            CharmUtil.createOkayAlertWith(error: error)
        }
    }
    
}

protocol CancelAppointmentViewControllerDelegate: AnyObject {
    func onAppointmentCancelled(indexPath: IndexPath?)
}
