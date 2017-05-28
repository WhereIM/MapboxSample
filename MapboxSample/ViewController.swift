//
//  ViewController.swift
//  MapboxSample
//
//  Created by Buganini Q on 29/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit
import Mapbox

// https://github.com/mapbox/mapbox-gl-Orig/issues/2167#issuecomment-192686761
func polygonCircleForCoordinate(coordinate: CLLocationCoordinate2D, withMeterRadius: Double) -> [CLLocationCoordinate2D] {
    let degreesBetweenPoints = 8.0
    let numberOfPoints = floor(360.0 / degreesBetweenPoints)
    let distRadians = withMeterRadius / 6371000.0
    let centerLatRadians = coordinate.latitude * Double.pi / 180
    let centerLonRadians = coordinate.longitude * Double.pi / 180
    var coordinates = [CLLocationCoordinate2D]()

    var i = 0
    while i < Int(numberOfPoints) {
        let degrees = Double(i) * Double(degreesBetweenPoints)
        let degreeRadians = degrees * Double.pi / 180
        let pointLatRadians = asin(sin(centerLatRadians) * cos(distRadians) + cos(centerLatRadians) * sin(distRadians) * cos(degreeRadians))
        let pointLonRadians = centerLonRadians + atan2(sin(degreeRadians) * sin(distRadians) * cos(centerLatRadians), cos(distRadians) - sin(centerLatRadians) * sin(pointLatRadians))
        let pointLat = pointLatRadians * 180 / Double.pi
        let pointLon = pointLonRadians * 180 / Double.pi
        let point: CLLocationCoordinate2D = CLLocationCoordinate2DMake(pointLat, pointLon)
        coordinates.append(point)
        i += 1
    }
    coordinates.append(coordinates[0])

    return coordinates
}

class WimPointAnnotation: MGLPointAnnotation {
    var userData: Any?
    var selected = false
    var icon: UIImage?
    var opacity = CGFloat(1.0)
    var zIndex = 0 // unused
}

class WimPolyline: MGLPolyline {
    var userData: Any? = UIColor.clear
    var opacity = CGFloat(1.0)
    var strokeWidth = CGFloat(3.0)
    var strokeColor = UIColor.clear
}

class ViewController: UIViewController, MGLMapViewDelegate {

    let npbtn = UIButton(type: UIButtonType.system)
    let epbtn = UIButton(type: UIButtonType.system)
    let nmbtn = UIButton(type: UIButtonType.system)
    let embtn = UIButton(type: UIButtonType.system)
    let mapView = MGLMapView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // polyline
        npbtn.translatesAutoresizingMaskIntoConstraints = false
        npbtn.setTitle("OrigPoly", for: .normal)
        npbtn.addTarget(self, action: #selector(origPolylineClicked(_:)), for: .touchUpInside)
        view.addSubview(npbtn)

        npbtn.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        npbtn.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        epbtn.translatesAutoresizingMaskIntoConstraints = false
        epbtn.setTitle("ExtendedPoly", for: .normal)
        epbtn.addTarget(self, action: #selector(extendedPolylineClicked(_:)), for: .touchUpInside)
        view.addSubview(epbtn)

        epbtn.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        epbtn.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        // marker
        nmbtn.translatesAutoresizingMaskIntoConstraints = false
        nmbtn.setTitle("OrigMarker", for: .normal)
        nmbtn.addTarget(self, action: #selector(origMarkerClicked(_:)), for: .touchUpInside)
        view.addSubview(nmbtn)

        nmbtn.topAnchor.constraint(equalTo: npbtn.bottomAnchor).isActive = true
        nmbtn.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true

        embtn.translatesAutoresizingMaskIntoConstraints = false
        embtn.setTitle("ExtendedMarker", for: .normal)
        embtn.addTarget(self, action: #selector(extendedMarkerClicked(_:)), for: .touchUpInside)
        view.addSubview(embtn)

        embtn.topAnchor.constraint(equalTo: epbtn.bottomAnchor).isActive = true
        embtn.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        mapView.translatesAutoresizingMaskIntoConstraints = false

        // Set the map’s center coordinate and zoom level.
        mapView.setCenter(CLLocationCoordinate2D(latitude: 59.31, longitude: 18.06), zoomLevel: 9, animated: false)
        view.addSubview(mapView)

        mapView.topAnchor.constraint(equalTo: nmbtn.bottomAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).isActive =  true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }

    func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return .yellow
    }

    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return .blue
    }

    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return CGFloat(0.7)
    }

    var latitude = 59.31
    var longitude = 18.06
    var step = 0.01

    var origPolyline: MGLPolyline?
    func origPolylineClicked(_ sender: Any) {
        if let p = origPolyline {
            self.mapView.removeAnnotation(p)
        }
        longitude += step
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let cs = polygonCircleForCoordinate(coordinate: center, withMeterRadius: 2500)
        let c = MGLPolyline(coordinates: cs, count: UInt(cs.count))
        self.mapView.addAnnotation(c)
        origPolyline = c
    }

    var extendedPolyline: WimPolyline?
    func extendedPolylineClicked(_ sender: Any) {
        if let p = extendedPolyline {
            self.mapView.removeAnnotation(p)
        }
        longitude += step
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let cs = polygonCircleForCoordinate(coordinate: center, withMeterRadius: 5000)
        let c = WimPolyline(coordinates: cs, count: UInt(cs.count))
        self.mapView.addAnnotation(c)
        extendedPolyline = c
    }

    var origMarker: MGLPointAnnotation?
    func origMarkerClicked(_ sender: Any) {
        if let p = origMarker {
            self.mapView.removeAnnotation(p)
        }
        longitude += step
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let c = MGLPointAnnotation()
        c.coordinate = center
        self.mapView.addAnnotation(c)
        origMarker = c
    }


    var extendedMarker: MGLPointAnnotation?
    func extendedMarkerClicked(_ sender: Any) {
        if let p = extendedMarker {
            self.mapView.removeAnnotation(p)
        }
        longitude += step
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let c = WimPointAnnotation()
        c.coordinate = center
        self.mapView.addAnnotation(c)
        extendedMarker = c
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

