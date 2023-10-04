//
//  SecondTableView.swift
//  Gocamping
//
//  Created by 康 on 2023/8/6.
//

import UIKit
import MapKit
import CoreLocation
import GooglePlaces

class SecondTableView: UITableView, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.dataSource = self
        self.delegate = self
        setupLocationManager()
        
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.dataSource = self
        self.delegate = self
        setupLocationManager()
        
    }
        
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CampManager.shared.camps.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "campCell", for: indexPath) as! CampCell
        
        let camps = CampManager.shared.camps
        let campID = camps[indexPath.row].camp_id
        let campName = camps[indexPath.row].camp_name
        cell.campName.text = campName
        cell.campLocation.text = camps[indexPath.row].camp_city
        NetworkManager.shared.getCampsImage(camp_id: campID) { result, statusCode, error in
            guard let imageURL = result?.image?.imageURL else {
                cell.campImage.image = UIImage(named: "風景照")
                return
            }
            if let image = CacheManager.shared.load(filename: imageURL) {
                cell.campImage.image = image
            } else {
                NetworkManager.shared.downloadImage(imageURL: imageURL) { data, error in
                    if let error = error {
                        print("Download image failed: \(error)")
                        cell.campImage.image = UIImage(named: "風景照")
                        return
                    }
                    
                    if let data = data {
                        cell.campImage.image = UIImage(data: data)
                        try? CacheManager.shared.save(data: data, filename: imageURL)
                        DispatchQueue.main.async {
                            tableView.reloadRows(at: [indexPath], with: .none)
                        }
                    }
                }
            }
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedCamp = CampManager.shared.camps[indexPath.row]
        navigateToCamp(camp: selectedCamp)
    }

    
    //MARK: Map
    func navigateToCamp(camp: Camp) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = camp.camp_name
        
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                //ShowMessageManager.shared.showToast(on: self, message: "無法獲取地圖資訊")
                return
            }
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            let mapItem = response.mapItems[0]
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            
            if let currentLocation = self.currentLocation {
                let userPlacemark = MKPlacemark(coordinate: currentLocation.coordinate)
                let userMapItem = MKMapItem(placemark: userPlacemark)
                
                let routes = [userMapItem, mapItem]
                MKMapItem.openMaps(with: routes, launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            } else {
                mapItem.openInMaps(launchOptions: launchOptions)
            }
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
        }
    }
    
}
