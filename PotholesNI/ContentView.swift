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
    @State private var location: MapCameraPosition = .userLocation(fallback: .automatic)
    
    func getPotholes() {
        if let apiUrl = URL(string: "https://potholes.dornar.uk/api/potholes/location/54.5,-7.6"){
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
            getPotholes()
            
        }
        Text("\(locationManager.region.center.latitude)")
        Text("\(locationManager.region.center.longitude)")
        
        Map(position: $location) {
            ForEach(potholes, id: \._id){pothole in
                Marker("\(pothole.defect_detail)", coordinate: CLLocationCoordinate2D(latitude: pothole.lat, longitude: pothole.lon))
            }
            
            
            
        }
        .onAppear(perform: {
            getPotholes()
        })
    

        
    }
    
}


#Preview {
    ContentView()
}
