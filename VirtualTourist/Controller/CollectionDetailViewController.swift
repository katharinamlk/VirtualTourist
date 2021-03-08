//
//  CollectionDetailViewController.swift
//  VirtualTourist
//
//  Created by Katharina Müllek on 25.02.21.
//

import UIKit
import MapKit
import CoreData

class CollectionDetailViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pin: Pin!
    var saveObserverToken: Any?
    var fetchedImages: [UIImage] = []
    var selectedPin: CLLocationCoordinate2D!
    let nib = UINib(nibName: "CollectionDetailViewCell", bundle: nil)
    
    override func viewWillAppear(_ animated: Bool) {
        setUpFetchedResultsController()
        showPin()
        newCollectionButton.title = "New Collection"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(nib, forCellWithReuseIdentifier: "CollectionDetailViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    // fetch ImageData
    func loadImage() {
        NetworkClient.getImageInformation(latitude: selectedPin.latitude, longitude: selectedPin.longitude, completionHandler: handleloadImageInformation(imageInformation:error:))
    }
    
    func handleloadImageInformation(imageInformation: Images?, error: Error?) {
        if let imageInformation = imageInformation {
            for image in imageInformation.photo {
                    NetworkClient.getImage(image: image, completion: handleGetImage(fetchedImage:error:))
            }
            
        } else {
            print(error!.localizedDescription)
        }
    }
    
    func handleGetImage(fetchedImage: UIImage?, error: Error?) {
        if let fetchedImage = fetchedImage {
            addPhoto(image: fetchedImage)
//            updateFetchedResults()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } else {
            print(error!.localizedDescription)
        }
    }
    
    // show the selected Pin
    func showPin() {
        let pin = MKPointAnnotation()
        pin.coordinate = selectedPin
        mapView.addAnnotation(pin)
        let region = MKCoordinateRegion(center: pin.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setRegion(region, animated: true)
    }
    
    func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "image", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        updateFetchedResults()
        
        if fetchedImages == [] {
            loadImage()
        }
    }
    
    func updateFetchedResults() {
        fetchedImages = []
        do {
            try fetchedResultsController.performFetch()
            if let images = fetchedResultsController.fetchedObjects {
                for image in images {
                    if let photoData = image.image {
                        if let dataImage = UIImage(data: photoData) {
                            fetchedImages.append(dataImage)
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    @IBAction func newCollectionPressed(_ sender: Any) {
        updateFetchedResults()
        loadImage()
    }

    


    //MARK: - Adding a Photo

    func addPhoto(image: UIImage) {
        let newPhoto = Photo(context: DataController.shared.viewContext)
        newPhoto.image = image.pngData()
        newPhoto.pin = pin
        DataController.shared.saveViewContext()
        updateFetchedResults()
    }
    
    func deletePhoto(_ indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        DataController.shared.viewContext.delete(photoToDelete)
        DataController.shared.saveViewContext()
        updateFetchedResults()
    }

}
