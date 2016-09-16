//
//  QRScanViewController.swift
//  LazyAccounting
//
//  Created by 梁浩 on 16/9/3.
//  Copyright © 2016年 LeungHowell. All rights reserved.
//

import UIKit

class QRScanViewController: LBXScanViewController {
    
    var delegate: QRScanResultDelegate?

    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        for result:LBXScanResult in arrayResult {
            delegate?.didScan(result.strScanned)
            navigationController?.popViewControllerAnimated(true)
        }
    }
}

protocol QRScanResultDelegate {
    func didScan(result: String?)
}
