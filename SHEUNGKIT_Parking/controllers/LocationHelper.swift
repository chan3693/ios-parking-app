//
//  LocationHelper.swift
//  SHEUNGKIT_Parking
//
//  Created by Simon Chan on 2024-07-09.
//

import Foundation
import CoreLocation

class LocationHelper : NSObject, ObservableObject, CLLocationManagerDelegate{
    
    private var geoCoder = CLGeocoder()
    private let locationManager : CLLocationManager = CLLocationManager()
    @Published var currLocation : CLLocation?
    private var authorizationStatus : CLAuthorizationStatus = .notDetermined
    
    @Published var lat : Double = 0.0
    @Published var lng : Double = 0.0
    @Published var location : String = ""
    
    private static var shared : LocationHelper?
    
    private override init(){
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.checkPermission()
    }
    
    static func getInstance() -> LocationHelper{
        if (shared == nil){
            self.shared = LocationHelper()
        }
        
        return self.shared!
    }
    
    func checkPermission(){
        switch self.locationManager.authorizationStatus{
        case .denied:
            print(#function, "location access denied")
            self.requestPermission()
        case .notDetermined:
            print(#function, "location access not determined")
            self.requestPermission()
        case .restricted:
            print(#function, "precise location not allowed by user")
        case .authorizedWhenInUse, .authorizedAlways:
            print(#function, "location access allowed...fetching device location")
            self.locationManager.startUpdatingLocation()
        @unknown default:
            print(#function, "Unable to determine location authorization")
        }
    }
    
    deinit{
        self.locationManager.stopUpdatingLocation()
    }
    
    func requestPermission(){
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager){
        print(#function, "Location authorization has changed : \(manager.authorizationStatus)")
        self.authorizationStatus = manager.authorizationStatus
        
        switch self.locationManager.authorizationStatus{
        case .denied, .notDetermined:
            self.locationManager.stopUpdatingLocation()
        case .restricted, .authorizedWhenInUse, .authorizedAlways:
            self.locationManager.startUpdatingLocation()
        @unknown default:
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager : CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if locations.last != nil{
            print(#function, "last location : \(locations.last)")
            self.currLocation = locations.last
        }else{
            print(#function, "old location : \(locations.first)")
            self.currLocation = locations.first
        }

        performReverseGeocoding(location: currLocation!)
    }
    
    func locationManager(_ manager : CLLocationManager, didFailWithError error : Error){
//        print(#function, "Unable to update the location : \(error)")
        if let CLError = error as? CLError {
                switch CLError.code {
                case .locationUnknown:
                    print("Location manager failed with error: Location Unknown")
                case .denied:
                    print("Location manager failed with error: Access Denied")
                default:
                    print("Location manager failed with error: \(CLError.localizedDescription)")
                }
            } else {
                print("Location manager failed with error: \(error.localizedDescription)")
            }
    }
    
    func performForwardGeocoding(address : String, completion: @escaping (Bool) -> Void){
        
        self.geoCoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in
            
            if (error != nil) {
                print(#function, "Unable to obtain coordinates for given address : \(error)")
                return
            }else{
                if let place = placemarks?.first{
                    let matchedLocation : CLLocation = place.location!
                    print(#function, "Matched Location : \(matchedLocation)")
                    print(#function, "Lat : \(matchedLocation.coordinate.latitude) Lng : \(matchedLocation.coordinate.longitude)")
                    
                    self.lat = matchedLocation.coordinate.latitude
                    self.lng = matchedLocation.coordinate.longitude
                    
                    completion(true)
                }else{
                    completion(false)
                }
            }
            
        })
        
        
    }
    func performReverseGeocoding(location : CLLocation){
        
        self.geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            
            if (error != nil) {
                print(#function, "Unable to obtain address for given location : \(error)")
                self.location = "No matching address"
                return
            }else{
                if let place = placemarks?.first{
                    print(#function, "Matching place : \(place)")
                    
                    let street = place.thoroughfare ?? "NA"
                    let city = place.subLocality ?? "NA"
                    let postalCode = place.postalCode ?? "NA"
                    let country = place.country ?? "NA"
                    let province = place.administrativeArea ?? "NA"
                    
                    self.location = "\(street). \(city). \(postalCode). \(province). \(country)"
                    return
                }
            }
        })
    }
    
    func getCurrLocation(){
        self.locationManager.startUpdatingLocation()
    }
}
