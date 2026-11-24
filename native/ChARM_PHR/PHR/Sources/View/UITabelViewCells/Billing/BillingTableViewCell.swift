//
//  BillingTableViewCell.swift
//  phr
//
//  Created by prathi-13964 on 22/12/22.
//  Copyright © 2022 Dhanuprasanya P. All rights reserved.
//

import UIKit

class BillingTableViewCell: UITableViewCell{
    let billingItemView = BillingItemView()
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initViews()  {
        contentView.backgroundColor = UIColorFromRGB(rgbValueWithAlpha: APPLICATION_BACKGROUND_COLOR)
        contentView.addSubview(billingItemView)
        addConstraints()
    }
    private func addConstraints(){
        billingItemView.addShadowAndCornerRadius(.SMALL)
        
        billingItemView.setHorizontal(offSet: X_SPACE)
        billingItemView.setTop(offSet: PADDING_5)
        billingItemView.setBottom(offSet: -PADDING_5)
    }
    
    func fetchInvoiceTableViewCell(data: PHRBills){
        billingItemView.setInvoice(bill: data)
    }
    
    func fetchReceiptTableViewCell(data: PHRReceipts){
        billingItemView.setReceipt(receipt: data)
    }
}
