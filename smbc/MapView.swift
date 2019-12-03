//
//  MapView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/24/19.
//  Copyright © 2019 Marco S Hyman. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//

import SwiftUI
import MapKit

/// MKMapView exposed to SwiftUI
struct MapView: UIViewRepresentable {
    let mapType: MKMapType
    let center: CLLocationCoordinate2D
    let altitude = 2000.0

    /// Coordinator class conforming to MKMapViewDelegate
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }

        /// return a pinAnnotationView for a red pin
        func mapView(_ mapView: MKMapView,
                     viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "pinAnnotation"
            var annotationView =
                mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if (annotationView == nil) {
                annotationView = MKPinAnnotationView(annotation: annotation,
                                                     reuseIdentifier: identifier)
                if let av = annotationView {
                    av.isEnabled = true
                    av.pinTintColor = .red
                    av.animatesDrop = false
                    av.canShowCallout = false
                    av.isDraggable = false
                } else {
                    fatalError("Can't create MKPinAnnotationView")
                }
            } else {
                annotationView!.annotation = annotation
            }
            return annotationView
        }
    }
    
    func makeCoordinator() -> MapView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let view = MKMapView(frame: .zero)
        view.delegate = context.coordinator
        view.camera = MKMapCamera(lookingAtCenter: center,
                                 fromEyeCoordinate: center,
                                 eyeAltitude: altitude)
        view.showsCompass = true
        view.mapType = mapType
        let pin = MKPointAnnotation()
        pin.coordinate = center;
        pin.title = "restaurant.name"
        view.addAnnotation(pin)
        return view
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
    }
}

/// Extension to map an MKMapType to a String
extension MKMapType {
    var name: String {
        switch self {
        case .standard:
            return "Map"
        case .hybrid:
            return "Hybrid"
        case .satellite:
            return "Satellite"
        default:
            return "Other"
        }
    }
}

#if DEBUG
struct MapView_Previews : PreviewProvider {
    static var previews: some View {
        MapView(mapType: .standard,
                center: CLLocationCoordinate2D(latitude: 37.7244,
                                               longitude: -122.4381))
    }
}
#endif
