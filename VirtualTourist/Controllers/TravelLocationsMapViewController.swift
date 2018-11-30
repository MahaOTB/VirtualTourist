//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Maha on 26/11/2018.
//  Copyright © 2018 Maha_AlOtaibi. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController {

    // MARK: Outlet
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Properties
    
    var pins = [Pin]()
    let segueToPhotoAlbumViewController = "segueToPhotoAlbumViewController"
    var annotationCoordinate: CLLocationCoordinate2D?
    lazy var viewContext: NSManagedObjectContext = {
       let appDelegate =  UIApplication.shared.delegate as! AppDelegate
       return appDelegate.persistentContainer.viewContext
    }()
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.delegate = self
        
        navigationController?.isToolbarHidden = true
        removeAllAnnotations()
        loadPins()
    }
    
    // MARK: Action
    
    @IBAction func longPressAction(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let pressedLocation = sender.location(in: mapView)
            let coordinate = mapView.convert(pressedLocation, toCoordinateFrom: mapView)
            
            addPin(latitude: coordinate.latitude, longitude: coordinate.longitude)
            savePin(coordinate)
        }
    }
    
    // MARK: Function
    
    func removeAllAnnotations() {
        
        let annotations: [MKAnnotation] = mapView.annotations
        
        guard annotations.count != 0 else {
            return
        }
        
        for annotation in annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    func loadPins() {
        activityIndicator.startAnimating()
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do {
            pins = try viewContext.fetch(fetchRequest)
            
            for pin in pins {
                addPin(latitude: pin.latitude, longitude: pin.longitude)
            }
            
        }catch {
            present(Alert.createUIAlert(title: Alert.ErrorTitle, message: error.localizedDescription), animated: true)
        }
        
        activityIndicator.stopAnimating()
    }
    
    func addPin(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = latitude
        annotation.coordinate.longitude = longitude
        
        mapView.addAnnotation(annotation)
    }
    
    func savePin(_ coordinate: CLLocationCoordinate2D) {
        let pin = Pin(context: viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        pin.collectionPage = 0
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                pins.append(pin)
            }catch {
                present(Alert.createUIAlert(title: Alert.ErrorTitle, message: error.localizedDescription), animated: true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueToPhotoAlbumViewController {
            let vc = segue.destination as! PhotoAlbumViewController

            guard let annotationCoordinate = annotationCoordinate else {return}
            
            let minLatitude = annotationCoordinate.latitude - 1.0
            let maxLatitude = annotationCoordinate.latitude + 1.0
            let minLongitude = annotationCoordinate.longitude - 1.0
            let maxLongitude = annotationCoordinate.longitude + 1.0
            
            let predicate = NSPredicate(format: "latitude >= \(minLatitude) AND latitude <= \(maxLatitude) AND longitude >= \(minLongitude) AND longitude <= \(maxLongitude)")
            
            let clickedPin = (pins as NSArray).filtered(using: predicate).first as? Pin
            vc.pin = clickedPin
            guard let photos = clickedPin?.photos?.allObjects as? [Photo] else {return}
            vc.photos = photos
        }
    }
}

extension TravelLocationsMapViewController: MKMapViewDelegate {
    
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        annotationCoordinate = view.annotation?.coordinate
        performSegue(withIdentifier: segueToPhotoAlbumViewController, sender: self)
        mapView.deselectAnnotation(view.annotation, animated: true)
    }
    
}
