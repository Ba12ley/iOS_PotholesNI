//
//  ContentView.swift
//  PotholesNI
//
//  Created by Adam Baizley on 24/03/2024.
//

import SwiftUI
import MapKit



struct Result: Codable {
    var data: [Pothole]
}

struct Pothole: Codable {
    public var _id : String
    public var instruction_reference: String
    public var defect_detail: String
    public var lat: Double
    public var lon: Double
}

struct ContentView: View {
    @State var potholes:[Pothole] = []
    @StateObject private var locationManager = LocationManager()
    @State private var location: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    
    func getPotholes(lat: Float, lon: Float) {
        if let apiUrl = URL(string: "https://potholes.dornar.uk/api/potholes/location/\(lat),\(lon)"){
            var request = URLRequest(url:apiUrl)
            request.httpMethod = "GET"
            print(request)
            URLSession.shared.dataTask(with: request){
                data, response, error in
                if let potholeData = data{
                    if let dataFromAPI =
                        try?JSONDecoder().decode(Result.self, from:potholeData){
                        potholes = dataFromAPI.data
                        print(potholes)
                    }
                    
                }
            }.resume()
        }
    }
    
    var body: some View {
        Button("Click me") {
            getPotholes(lat: Float(locationManager.region.center.latitude), lon: Float(locationManager.region.center.longitude))
            
        }
        Text("\(locationManager.region.center.latitude)")
        Text("\(locationManager.region.center.longitude)")
        
        Map(position: $location) {
            ForEach(potholes, id: \._id){pothole in
                Marker("\(pothole.defect_detail)", systemImage: "hazardsign", coordinate: CLLocationCoordinate2D(latitude: pothole.lat, longitude: pothole.lon))
            }
            
            
            
        }
        .onAppear(perform: {
            getPotholes(lat: Float(locationManager.region.center.latitude), lon: Float(locationManager.region.center.longitude))
        })
        .mapStyle(.standard)
        
        
        
        
    }
    
}


#Preview {
    ContentView()
}
