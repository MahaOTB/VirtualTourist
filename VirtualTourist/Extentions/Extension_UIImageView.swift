//
//  Extension_UIImageView.swift
//  Virtual Tourist
//
//  Created by Maha on 28/11/2018.
//  Copyright © 2018 Maha_AlOtaibi. All rights reserved.
//

import Foundation
import UIKit
import Alamofire


let imageCatch = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    typealias handleError = (Data?, Error?) -> Void
    
    func loadImageUsingURLString(urlString: String, complition: @escaping handleError) {
       
        // Check if the image is loaded before
        if let loadedImage = imageCatch.object(forKey: urlString as NSString) as? UIImage {
            self.image = loadedImage
            let imageData = loadedImage.jpegData(compressionQuality: 0.0)
            complition(imageData, nil)
            return
        }
        
        image = nil
        
        Alamofire.request(urlString).responseData { response in
            
            switch response.result {
            case .success:
                if let data = response.result.value {
                    
                    DispatchQueue.main.async {
                        if let loadedImage = UIImage(data: data) {
                            imageCatch.setObject(loadedImage, forKey: urlString as NSString)
                            self.image = loadedImage
                            let imageData = loadedImage.jpegData(compressionQuality: 0.0)
                            complition(imageData, nil)
                        }
                        
                    }
                }
            
            case .failure(let error):
                complition(nil, error)
            }
        }
    }
}
