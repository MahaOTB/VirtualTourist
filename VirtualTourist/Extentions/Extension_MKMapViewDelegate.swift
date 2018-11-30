//
//  Extension_MKMapViewDelegate.swift
//  Virtual Tourist
//
//  Created by Maha on 30/11/2018.
//  Copyright © 2018 Maha_AlOtaibi. All rights reserved.
//

import Foundation
import MapKit

extension PhotoAlbumViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        
        let reuseId = "Pin"
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pin == nil {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }else {
            pin?.annotation = annotation
        }
        
        pin?.animatesDrop = true
        
        return pin
    }
}
