//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Maha on 27/11/2018.
//  Copyright © 2018 Maha_AlOtaibi. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Alamofire

class PhotoAlbumViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var barButtnewCollection: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Properties
    
    var imagesUrl = [PhotoUrl]()
    var photos = [Photo]()
    static var noOfImagesDownloaded = 0
    let reusedCellId = "FlickerPhoto"
    var pin: Pin?
    lazy var viewContext: NSManagedObjectContext = {
        let appDelegate =  UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    // MARK: LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        mapView.delegate = self
        
        if photos.count == 0 {
            loadPhotosFromFlicker()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupCollectionViewItem(space: 3.0)
        setUI(isEnabeled: false)
        navigationController?.isToolbarHidden = false
        
        PhotoAlbumViewController.noOfImagesDownloaded = 0
        
        setPinLocation(pin)
    }
    
    // MARK: Actions
    
    @IBAction func newCollctionTapped(_ sender: UIBarButtonItem) {
        PhotoAlbumViewController.noOfImagesDownloaded = 0
        removeOldCollection()
        setUI(isEnabeled: false)
        loadPhotosFromFlicker()
    }
    
    
    // MARK: Functions
   
    func removeOldCollection() {
        
        for photo in photos {
            viewContext.delete(photo)
        }
        
        photos.removeAll()
        imagesUrl.removeAll()
    }
    
    func setPinLocation(_ pin: Pin?) {
        guard let pin = pin  else {return}
        
        let currentLocation = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let region = MKCoordinateRegion(center: currentLocation, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = currentLocation
        
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
    }
    
    func loadPhotosFromFlicker() {
        guard let latitude = pin?.latitude, let longitude = pin?.longitude, var page = pin?.collectionPage else {return}
        let imagePerPage = 12
        
        page += 1
        
        NetworkClient.requestURLPhotos(latitude: latitude, longitude: longitude, page: Int(page)) { (photos, error) in
            
            if !self.hasError(error) {
                self.imagesUrl.append(contentsOf: photos!)
                self.isEmptyResult()
                
                // if # of photos less than 12 then at the next loaded go to page no #1
                // else save current page
                if self.imagesUrl.count < imagePerPage {
                    self.pin?.setValue(0 , forKey: "collectionPage")
                }else {
                    self.pin?.setValue(page, forKey: "collectionPage")
                }
                
                self.collectionView.reloadData()
            }
        }
    }
    
    func storePhoto(_ photoData: Data) {
        guard let pin = pin else {return}
        
        let photo = Photo(context: viewContext)
        photo.photoData = photoData
        photo.pin = pin
        
        photos.append(photo)
        PhotoAlbumViewController.noOfImagesDownloaded += 1
        
        if PhotoAlbumViewController.noOfImagesDownloaded == imagesUrl.count {
            self.imagesUrl.removeAll()
            self.setUI(isEnabeled: true)
        }
        
        do {
            try viewContext.save()
        }catch {
            present(Alert.createUIAlert(title: Alert.ErrorTitle, message: error.localizedDescription), animated: true)
        }
    }
    
    func hasError(_ error: Error?) -> Bool {
        guard error == nil else {
            self.present(Alert.createUIAlert(title: Alert.ErrorTitle, message: error!.localizedDescription), animated: true)
            return true
        }
        return false
    }
    
    func setupCollectionViewItem (space: CGFloat){
        let space:CGFloat = 3
        let width = (collectionView.frame.size.width - (2 * space))/3
        let hight = (collectionView.frame.size.height - (2 * space))/4
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: hight)
    }
    
    fileprivate func loadImage(_ cell: FlickerPhotoCollectionViewCell, _ indexPath: IndexPath) {
        cell.photoImageView.loadImageUsingURLString(urlString: imagesUrl[indexPath.row].url) { (loadedImage, error) in
            
            cell.activityIndicator.stopAnimating()
            
            if !self.hasError(error) {
                if let loadedImage = loadedImage {
                    self.storePhoto(loadedImage)
                }
    
            }
        }
    }
    
    fileprivate func isEmptyResult() {
        if imagesUrl.count == 0 {
            collectionView.setEmptyMessage("No results found :(")
        }else {
            collectionView.restore()
        }
    }
    
    func setUI(isEnabeled: Bool){
        barButtnewCollection.isEnabled = isEnabeled
    }
    
}

// MARK: UICollectionViewDataSource methods

extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if photos.count == 0 {
            return imagesUrl.count
        }
    
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusedCellId, for: indexPath) as! FlickerPhotoCollectionViewCell
        
        cell.activityIndicator.startAnimating()
        
        if imagesUrl.count != 0 {
            loadImage(cell, indexPath)
        } else {
            cell.photoImageView.image = UIImage(data: photos[indexPath.row].photoData!)
            cell.activityIndicator.stopAnimating()
            
            PhotoAlbumViewController.noOfImagesDownloaded += 1
            if PhotoAlbumViewController.noOfImagesDownloaded == photos.count {
                setUI(isEnabeled: true)
            }
        }
        
        return cell
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if barButtnewCollection.isEnabled {
            if photos.count != 0 {
                let removedObject = photos.remove(at: indexPath.row)
                collectionView.deleteItems(at: [indexPath])
                viewContext.delete(removedObject)
            }
        }
    }
    
}
