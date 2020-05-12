//
//  AlbumViewController.swift
//  VirtualTourist
//
//  Created by Pjcyber on 4/29/20.
//  Copyright © 2020 Pjcyber. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class AlbumViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Variables
    var dataController: DataController!
    var pin: Pin!
    var photos = [Photo]()
    var photosResponse = [PhotoResponse]()
    let photosCount = 60
    
    // MARK: - UIViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPhotosFromCoreData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showMaplocation(pin)
    }
    
    // MARK: - Actions
    @IBAction func reFetchAlbum(_ sender: Any) {
        self.photos = [Photo]()
        self.photosResponse = [PhotoResponse]()
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin!)
        fetchRequest.predicate = predicate
        do {
            let photos = try DataController.context.fetch(fetchRequest)
            for photo in photos {
                DataController.context.delete(photo)
                DataController.saveContext()
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            fetchPhotos()
        } catch {
            let nerror = error as NSError
            fatalError("DataController error \(nerror.localizedDescription)")
        }
    }
    
    
    // MARK: - Helpers
    fileprivate func showMaplocation(_ pin: Pin?) {
        guard let point = pin else {
            return
        }
        
        let latitude = Double(point.latitude!)!
        let longitude = Double(point.longitude!)!
        let delta = 0.01
        let center = CLLocationCoordinate2DMake(latitude, longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
        
        mapView.setRegion(region, animated: true)
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        mapView.addAnnotation(annotation)
        mapView.setCenter(center, animated: true)
    }
    
    fileprivate func fetchPhotosFromCoreData() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin!)
        fetchRequest.predicate = predicate
        do {
            let photos = try DataController.context.fetch(fetchRequest)
            if photos.isEmpty {
                fetchPhotos()
            } else {
                self.photos = photos
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        } catch {
            let nerror = error as NSError
            fatalError("DataController error \(nerror.localizedDescription)")
        }
    }
    
    fileprivate func fetchPhotos() {
        FlickrClient.fethAlbum(pin: pin, count: String(photosCount)) { photosResponse, error in
            if error == nil {
                if photosResponse.isEmpty {
                    self.showErrorAlert(title: "Error", message: "No photos found for this location")
                }
                self.photosResponse = photosResponse
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } else {
                self.showErrorAlert(title: "Error fetching Photos", message: error.debugDescription)
            }
        }
    }
    
    fileprivate func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension AlbumViewController: MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let id = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: id)
            pinView!.pinTintColor = .red
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.isEmpty ? photosCount : photos.count
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.cellIdentifier,
                                                      for: indexPath) as! ImageCollectionViewCell
        cell.progressBar.startAnimating()
        if photos.indices.contains(indexPath.item) {
            let photo = photos[indexPath.item]
            cell.progressBar.stopAnimating()
            cell.imageView.image = UIImage(data: photo.image!)
        } else if photosResponse.indices.contains(indexPath.item) {
            let photoResponse =  photosResponse[indexPath.item]
            FlickrClient.downloadImage(photo: photoResponse) { (url, data, error) in
                if let data = data, error == nil {
                    let photo = Photo(context: DataController.context)
                    photo.pin = self.pin
                    photo.url = url
                    photo.image = data
                    DataController.saveContext()
                    self.photos.append(photo)
                    DispatchQueue.main.async {
                        cell.progressBar.stopAnimating()
                        cell.imageView.image = UIImage(data: photo.image!)
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.imageView.image = nil
                        cell.progressBar.stopAnimating()
                    }
                }
            }
        } else {
            cell.imageView.image = nil
            cell.progressBar.stopAnimating()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photos[indexPath.item]
        photos.remove(at: indexPath.item)
        DataController.context.delete(photo)
        DataController.saveContext()
        collectionView.deleteItems(at: [indexPath])
     }
}
