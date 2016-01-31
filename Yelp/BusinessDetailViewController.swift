//
//  BusinessDetailViewController.swift
//  Yelp
//
//  Created by Nicholas Miller on 1/31/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class BusinessDetailViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var business: Business!
    
    @IBOutlet weak var businessImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingsImageView: UIImageView!
    @IBOutlet weak var reviewsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager : CLLocationManager!
    
    var longitude: CLLocationDegrees = 0.0
    var latitude: CLLocationDegrees = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 100
        locationManager.requestWhenInUseAuthorization()
        
        let centerLocation = CLLocation(latitude: latitude, longitude: longitude)
        goToLocation(centerLocation)
        
        if (business.imageURL != nil) {
            businessImageView.setImageWithURL(business.imageURL!)
        }
        if (business.name != nil) {
            nameLabel.text = business.name!
        }
        if (business.distance != nil) {
            distanceLabel.text = business.distance
        }
        if (business.ratingImageURL != nil) {
            ratingsImageView.setImageWithURL(business.ratingImageURL!)
        }
        if (business.reviewCount != nil) {
            reviewsLabel.text = "\(business.reviewCount!) Reviews"
        }
        if (business.address != nil) {
            addressLabel.text = business.address
        }
        if (business.categories != nil) {
            descriptionLabel.text = business.categories
        }
        
        mapView.layer.cornerRadius = 5
        mapView.clipsToBounds = true
        
        if (business.address != nil && business.name != nil) {
            addByAddress(business.address!, name: business.name!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region = MKCoordinateRegionMake(location.coordinate, span)
            mapView.setRegion(region, animated: false)
            
            longitude = location.coordinate.longitude
            latitude = location.coordinate.latitude
            
            //            var place = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
            //            addAnnotationAtCoordinateCLL("My annotation", place: place)
            
            // draw circular overlay centered in San Francisco
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let circleOverlay: MKCircle = MKCircle(centerCoordinate: coordinate, radius: 400)
            mapView.addOverlay(circleOverlay)
        }
    }
    
    func addByAddress(address: String, name: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            
            if let placemark = (placemarks![0]) as? CLPlacemark {
                self.addAnnotationAtCoordinate(name, place: MKPlacemark(placemark: placemark))
            }
        })
    }
    
    func addAnnotationAtCoordinate(name: String, place: MKPlacemark) {
        let placeLat = place.coordinate.latitude
        let placeLong = place.coordinate.longitude
        
        let annotation = MKPointAnnotation()
        annotation.title = name
        annotation.coordinate.latitude = placeLat
        annotation.coordinate.longitude = placeLong
        mapView.addAnnotation(annotation)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "customAnnotationView"
        // custom pin annotation
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
        
        if (annotation.coordinate.latitude != self.latitude && annotation.coordinate.longitude != self.longitude) {
            if (annotationView == nil) {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            else {
                annotationView!.annotation = annotation
            }
            
            if #available(iOS 9.0, *) {
                annotationView!.pinTintColor = UIColor.redColor()
            } else {
                // Fallback on earlier versions
            }
            
            // annotationView!.image = UIImage(named: "customAnnotationImage")
            
        }
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circleView = MKCircleRenderer(overlay: overlay)
        circleView.strokeColor = UIColor.redColor()
        circleView.lineWidth = 1
        return circleView
    }

}
