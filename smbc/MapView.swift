//
//  MapView.swift
//  smbc
//
//  Created by Marco S Hyman on 6/24/19.
//

import SwiftUI
import MapKit

/// MKMapView exposed to SwiftUI
///
@available(iOS, deprecated: 14.0, message: "Use the built-in Map API instead")
struct MapView: UIViewRepresentable {
    let mapType: MKMapType
    let center: CLLocationCoordinate2D
    let altitude = 2000.0

    /// Coordinator class conforming to MKMapViewDelegate
    class Coordinator: NSObject, MKMapViewDelegate {
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
        Coordinator()
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
        view.mapType = mapType
        view.camera = MKMapCamera(lookingAtCenter: center,
                                 fromEyeCoordinate: center,
                                 eyeAltitude: altitude)
        let pin = MKPointAnnotation()
        pin.coordinate = center;
        pin.title = "restaurant.name"
        view.addAnnotation(pin)
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
