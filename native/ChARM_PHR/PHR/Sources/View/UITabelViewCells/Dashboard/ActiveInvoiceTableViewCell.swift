//
//  ActiveInvoiceTableViewCell.swift
//  phr
//
//  Created by Raghul D on 04/03/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import Foundation

class ActiveInvoiceTableViewCell: UITableViewCell {
    
    let activeInvoiceIndividualView = ActiveInvoiceIndividualView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        contentView.addSubview(activeInvoiceIndividualView)
        addConstraints()
    }
    
    private func addConstraints()
    {
        activeInvoiceIndividualView.setLeft(offSet: 0)
        activeInvoiceIndividualView.setRight(offSet: 0)
        activeInvoiceIndividualView.setTop(offSet: 0)
        activeInvoiceIndividualView.setBottom(offSet: 0)
    }
    
    func setValues(phrBill: PHRBills)
    {
        activeInvoiceIndividualView.setValues(phrBill: phrBill)
    }
}
