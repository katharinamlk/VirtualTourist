//
//  MapPinViewController.swift
//  VirtualTourist
//
//  Created by Katharina Müllek on 25.02.21.
//

import UIKit
import MapKit
import CoreData

class MapPinViewController: UIViewController, NSFetchedResultsControllerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var selectedPinLocation: CLLocationCoordinate2D!
    var newCoordinates: CLLocationCoordinate2D!
    var annotations = [MKPointAnnotation]()
    var pins: [Pin] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(recognizeLongPress(pressGesture:)))
        mapView.addGestureRecognizer(longPressRecognizer)
        loadPersistenceMap()
        fetchLocations()
    }
    
    func fetchLocations() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            if let pins = fetchedResultsController.fetchedObjects {
                self.pins = pins
                // remove all existing pins to not have multiple on top of each other
                annotations.removeAll()
                // populate the map with the pins!
                for pin in pins {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                    annotations.append(annotation)
                    self.mapView.addAnnotations(annotations)
                }
            }
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }

    }
    
//MARK: - Adding a new Pin
    
    // Create a Pin when UI is pressed prolonged time
    @objc func recognizeLongPress(pressGesture: UILongPressGestureRecognizer) {
        // to only generate one pin no matter how long someone is pressing
        if pressGesture.state != UIGestureRecognizer.State.began {
            return
        }
        let newLocation = pressGesture.location(in: mapView)
        let newCoordinates: CLLocationCoordinate2D = mapView.convert(newLocation, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        mapView.addAnnotation(annotation)
        addPin(coordinates: newCoordinates)
    }
    
    func addPin(coordinates: CLLocationCoordinate2D) {
        let newPin = Pin(context: DataController.shared.viewContext)
        newPin.latitude = coordinates.latitude
        newPin.longitude = coordinates.longitude
        DataController.shared.saveViewContext()
        fetchLocations()
    }
    
    // return the specific CoreData <Pin> in regards to latitude & longitude
    func returnSelectedPin(latitude: Double, longitude: Double) -> Pin {
        for pin in pins {
            if (pin.latitude == latitude && pin.longitude == longitude) {
                return pin
            }
        }
        return Pin()
    }
    
    // return the defined Pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
//MARK: - Segue
    // Perform segue if existing Pin is pressed
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedPinLocation = view.annotation?.coordinate
        performSegue(withIdentifier: "collectionViewSegue", sender: self)

    }
    
    // prepare the segue to pass the right values for your pin and call the right collection
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let collectionVC = segue.destination as! CollectionDetailViewController

        collectionVC.selectedPin = selectedPinLocation
        collectionVC.pin = returnSelectedPin(latitude: selectedPinLocation.latitude, longitude: selectedPinLocation.longitude)
    }


//MARK: - Location Persistence
    // check for the first Launch
    func loadPersistenceMap() {
        if UserDefaults.standard.value(forKey: "loggedLocation") != nil {
            let latitude = UserDefaults.standard.double(forKey: "lastLatitude")
            let longitude = UserDefaults.standard.double(forKey: "lastLongitude")
            let latitudeSpan = UserDefaults.standard.double(forKey: "lastLatitudeSpan")
            let longitudeSpan = UserDefaults.standard.double(forKey: "lastLongitudeSpan")
            let lastLoggedLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            mapView.region = MKCoordinateRegion(center: lastLoggedLocation, span: MKCoordinateSpan(latitudeDelta: latitudeSpan, longitudeDelta: longitudeSpan))
        } else {
            UserDefaults.standard.setValue(true, forKey: "loggedLocation")
        }
    }

    // Set the UserDefaults every time the Map was moved
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        let region = mapView.region.center
        let lastLoggedLatitude = region.latitude
        UserDefaults.standard.set(lastLoggedLatitude, forKey: "lastLatitude")
        let lastLoggedLongitude = region.longitude
        UserDefaults.standard.set(lastLoggedLongitude, forKey: "lastLongitude")
        let latitudeSpan = mapView.region.span.latitudeDelta
        UserDefaults.standard.set(latitudeSpan, forKey: "lastLatitudeSpan")
        let longitudeSpan = mapView.region.span.longitudeDelta
        UserDefaults.standard.set(longitudeSpan, forKey: "lastLongitudeSpan")
        UserDefaults.standard.synchronize()
    }
}
