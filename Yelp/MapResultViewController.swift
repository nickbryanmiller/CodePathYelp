//
//  MapResultViewController.swift
//  Yelp
//
//  Created by Nicholas Miller on 1/26/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapResultViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
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
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
        
        let centerLocation = CLLocation(latitude: latitude, longitude: longitude)
        goToLocation(centerLocation)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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
            
            // draw circular overlay centered in San Francisco
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let circleOverlay: MKCircle = MKCircle(centerCoordinate: coordinate, radius: 1000)
            mapView.addOverlay(circleOverlay)
        }
    }
    
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "An annotation!"
        mapView.addAnnotation(annotation)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "customAnnotationView"
        // custom pin annotation
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
        if (annotationView == nil) {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        else {
            annotationView!.annotation = annotation
        }
        
        if #available(iOS 9.0, *) {
            annotationView!.pinTintColor = UIColor.greenColor()
        } else {
            // Fallback on earlier versions
        }
        
//        annotationView!.image = UIImage(named: "customAnnotationImage")
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circleView = MKCircleRenderer(overlay: overlay)
        circleView.strokeColor = UIColor.redColor()
        circleView.lineWidth = 1
        return circleView
    }

}
