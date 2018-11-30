//
//  Alert.swift
//  Virtual Tourist
//
//  Created by Maha on 26/11/2018.
//  Copyright © 2018 Maha_AlOtaibi. All rights reserved.
//

import Foundation
import UIKit

struct Alert {
    
    static let AlertDismiss = "Ok"
    static let ErrorTitle = "Error"
    
    static func createUIAlert(title: String = "", message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alert.AlertDismiss, style: .cancel, handler: nil))
        
        return alert
    }
}
