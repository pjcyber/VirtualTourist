//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Pjcyber on 4/24/20.
//  Copyright © 2020 Pjcyber. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class UIMapViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    // MARK: - Variables
    var editMode: Bool = false
    var annotation: MKPointAnnotation?
    var pins = [Pin]()
    let dataController = DataController.shared
    
    // MARK: - UIViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPinsFromCoreData()
        loadPins(pins)
    }
    
    // MARK: - Actions
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: mapView)
        let coordinates = mapView.convert(location, toCoordinateFrom: mapView)
        if !editMode {
            if sender.state == .began {
                annotation = MKPointAnnotation()
                annotation!.coordinate = coordinates
                mapView.addAnnotation(annotation!)
            } else if sender.state == .changed {
                annotation!.coordinate = coordinates
            } else if sender.state == .ended {
                let pin = Pin(context: dataController.context)
                pin.latitude = String(annotation!.coordinate.latitude)
                pin.longitude = String(annotation!.coordinate.longitude)
                dataController.saveContext()
                pins.append(pin)
            }
        }
    }
    
    @IBAction func enableEditMode(_ sender: Any) {
        if editMode {
            editMode = false
            editButton.title = "Delete Pin"
        } else {
            editMode = true
            editButton.title = "Add Pin"
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AlbumViewController {
            guard let pin = sender as? Pin else {
                return
            }
            
            let albumViewController = segue.destination as? AlbumViewController
            albumViewController?.pin = pin
        }
    }
    
    // MARK: - Helpers
    fileprivate func fetchPinsFromCoreData() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        do {
            let pins = try dataController.context.fetch(fetchRequest)
            self.pins = pins
        } catch {
            let nerror = error as NSError
            fatalError("DataController error \(nerror.localizedDescription)")
        }
    }
    
    fileprivate func loadPins(_ pins: [Pin]) {
        for pin in pins where pin.latitude != nil && pin.longitude != nil {
            let latitude = Double(pin.latitude!)!
            let longitude = Double(pin.longitude!)!
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            mapView.addAnnotation(annotation)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
}

extension UIMapViewController: MKMapViewDelegate {
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let id = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: id)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            return
        }
        let latitude = String(annotation.coordinate.latitude)
        let longitude = String(annotation.coordinate.longitude)
        var position = 0
        for pin in pins {
            if pin.latitude == latitude && pin.longitude == longitude {
                if editMode {
                    pins.remove(at: position)
                    dataController.context.delete(pin)
                    dataController.saveContext()
                    mapView.removeAnnotation(annotation)
                    return
                } else {
                    mapView.deselectAnnotation(annotation, animated: true)
                    performSegue(withIdentifier: "goToAlbum", sender: pin)
                }
            }
            position += 1
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation else {
            return
        }
        if control == view.rightCalloutAccessoryView {
            var position = 0
            for pin in pins {
                if pin.latitude == String(annotation.coordinate.latitude) && pin.longitude == String(annotation.coordinate.longitude) {
                    if editMode {
                        pins.remove(at: position)
                        dataController.context.delete(pin)
                        dataController.saveContext()
                        mapView.removeAnnotation(annotation)
                    } else {
                        mapView.deselectAnnotation(annotation, animated: true)
                        performSegue(withIdentifier: "goToAlbum", sender: pin)
                    }
                    
                }
                position += 1
            }
        }
    }
}
