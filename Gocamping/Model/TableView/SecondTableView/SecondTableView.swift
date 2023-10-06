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
    
    // MARK: Initialize
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        commonInit()
        setupLocationManager()
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
        setupLocationManager()
    }
    
    private func commonInit() {
        self.dataSource = self
        self.delegate = self
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
        
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CampManager.shared.camps.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configuraCampCell(for: tableView, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedCamp = CampManager.shared.camps[indexPath.row]
        navigateToCamp(camp: selectedCamp)
    }
    // MARK: - Data for campCell
    private func configuraCampCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "campCell", for: indexPath) as! CampCell
        let camps = CampManager.shared.camps
        let campID = camps[indexPath.row].camp_id
        let campName = camps[indexPath.row].camp_name
        
        cell.campName.text = campName
        cell.campLocation.text = camps[indexPath.row].camp_city
        cell.backgroundColor = UIColor.clear
        
        getCampImage(campID: campID, for: cell, with: tableView, at: indexPath)
        
        return cell
    }
    // MARK: - Get camps image
    private func getCampImage(campID: Int, for cell: CampCell, with tableView: UITableView, at indexPath: IndexPath) {
        ImageNetworkManager.shared.getCampsImage(camp_id: campID) { result, statusCode, error in
            guard let imageURL = result?.image?.imageURL else {
                cell.campImage.image = UIImage(named: "風景照")
                return
            }
            self.downloadCampImage(imageURL: imageURL, for: cell, with: tableView, at: indexPath)
        }
    }
    
    private func downloadCampImage(imageURL: String, for cell: CampCell, with tableView: UITableView, at indexPath: IndexPath) {
        ImageNetworkManager.shared.downloadOrLoadImage(imageURL: imageURL) { data, error in
            if let data = data {
                cell.campImage.image = UIImage(data: data)
            } else {
                cell.campImage.image = UIImage(named: "風景照")
            }
            
        }
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
    

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
        }
    }
    
}
