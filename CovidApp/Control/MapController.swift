//
//  MapController.swift
//  CovidApp
//
//  Created by Tingyu Song on 1/10/20.
//  Copyright © 2020 A1_Group_3. All rights reserved.
//

import UIKit
import Mapbox

class MapController: UIViewController, UITabBarDelegate,MGLMapViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var map: UIView!
    
    @IBOutlet weak var Tabbar: UITabBar!
    var mapView:MGLMapView!
    var icon: UIImage!
    var popup: UIView?
    var userdata_:UserData!
    
    enum CustomError: Error {
        case castingError(String)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Tabbar.delegate = self
        userdata_ = UD
        // map initialization
        mapView = MGLMapView(frame: self.map.bounds, styleURL: MGLStyle.lightStyleURL)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.tintColor = .darkGray
        mapView.showsUserLocation = true
        mapView.delegate = self
        self.map.addSubview(mapView)
        
        // Add a double tap gesture recognizer. This gesture is used for double
        // tapping on clusters and then zooming in so the cluster expands to its
        // children.
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapCluster(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        
        // It's important that this new double tap fails before the map view's
        // built-in gesture can be recognized. This is to prevent the map's gesture from
        // overriding this new gesture (and then not detecting a cluster that had been
        // tapped on).
        for recognizer in mapView.gestureRecognizers!
            where (recognizer as? UITapGestureRecognizer)?.numberOfTapsRequired == 2 {
                recognizer.require(toFail: doubleTap)
        }
        mapView.addGestureRecognizer(doubleTap)
        
        // Add a single tap gesture recognizer. This gesture requires the built-in
        // MGLMapView tap gestures (such as those for zoom and annotation selection)
        // to fail (this order differs from the double tap above).
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(sender:)))
        for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
            singleTap.require(toFail: recognizer)
        }
        mapView.addGestureRecognizer(singleTap)
        
        icon = UIImage(named: "port")
        
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "allcountries", ofType: "geojson")!)
        
        let source = MGLShapeSource(identifier: "clusteredPorts",
                                    url: url,
                                    options: [.clustered: true, .clusterRadius: icon.size.width])
        style.addSource(source)
        
        // Use a template image so that we can tint it with the `iconColor` runtime styling property.
        style.setImage(icon.withRenderingMode(.alwaysTemplate), forName: "icon")
        
        // Show unclustered features as icons. The `cluster` attribute is built into clustering-enabled
        // source features.
        let ports = MGLSymbolStyleLayer(identifier: "ports", source: source)
        ports.iconImageName = NSExpression(forConstantValue: "icon")
        ports.iconColor = NSExpression(forConstantValue: UIColor.darkGray.withAlphaComponent(0.9))
        ports.predicate = NSPredicate(format: "cluster != YES")
        ports.iconAllowsOverlap = NSExpression(forConstantValue: true)
        style.addLayer(ports)
        
        // Color clustered features based on clustered point counts.
        let stops = [
            2: UIColor.lightGray,
            5: UIColor.orange,
            10: UIColor.red,
            20: UIColor.purple
        ]
        
        // Show clustered features as circles. The `point_count` attribute is built into
        // clustering-enabled source features.
        let circlesLayer = MGLCircleStyleLayer(identifier: "clusteredPorts", source: source)
        circlesLayer.circleRadius = NSExpression(forConstantValue: NSNumber(value: Double(icon.size.width) / 2))
        circlesLayer.circleOpacity = NSExpression(forConstantValue: 0.75)
        circlesLayer.circleStrokeColor = NSExpression(forConstantValue: UIColor.white.withAlphaComponent(0.75))
        circlesLayer.circleStrokeWidth = NSExpression(forConstantValue: 2)
        circlesLayer.circleColor = NSExpression(format: "mgl_step:from:stops:(point_count, %@, %@)", UIColor.lightGray, stops)
        circlesLayer.predicate = NSPredicate(format: "cluster == YES")
        style.addLayer(circlesLayer)
        
        // Label cluster circles with a layer of text indicating feature count. The value for
        // `point_count` is an integer. In order to use that value for the
        // `MGLSymbolStyleLayer.text` property, cast it as a string.
        let numbersLayer = MGLSymbolStyleLayer(identifier: "clusteredPortsNumbers", source: source)
        numbersLayer.textColor = NSExpression(forConstantValue: UIColor.white)
        numbersLayer.textFontSize = NSExpression(forConstantValue: NSNumber(value: Double(icon.size.width) / 2))
        numbersLayer.iconAllowsOverlap = NSExpression(forConstantValue: true)
        numbersLayer.text = NSExpression(format: "CAST(point_count, 'NSString')")
        
        numbersLayer.predicate = NSPredicate(format: "cluster == YES")
        style.addLayer(numbersLayer)
    }
    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        showPopup(false, animated: false)
    }
    
    private func firstCluster(with gestureRecognizer: UIGestureRecognizer) -> MGLPointFeatureCluster? {
        let point = gestureRecognizer.location(in: gestureRecognizer.view)
        let width = icon.size.width
        let rect = CGRect(x: point.x - width / 2, y: point.y - width / 2, width: width, height: width)
        
        // This shows how to check if a feature is a cluster by
        // checking for that the feature is a `MGLPointFeatureCluster`. Alternatively, you could
        // also check for conformance with `MGLCluster` instead.
        let features = mapView.visibleFeatures(in: rect, styleLayerIdentifiers: ["clusteredPorts", "ports"])
        let clusters = features.compactMap { $0 as? MGLPointFeatureCluster }
        
        // Pick the first cluster, ideally selecting the one nearest nearest one to
        // the touch point.
        return clusters.first
    }
    
    @objc func handleDoubleTapCluster(sender: UITapGestureRecognizer) {
        
        guard let source = mapView.style?.source(withIdentifier: "clusteredPorts") as? MGLShapeSource else {
            return
        }
        
        guard sender.state == .ended else {
            return
        }
        
        showPopup(false, animated: false)
        
        guard let cluster = firstCluster(with: sender) else {
            return
        }
        
        let zoom = source.zoomLevel(forExpanding: cluster)
        
        if zoom > 0 {
            mapView.setCenter(cluster.coordinate, zoomLevel: zoom, animated: true)
        }
    }
    
    @objc func handleMapTap(sender: UITapGestureRecognizer) {
        
        guard let source = mapView.style?.source(withIdentifier: "clusteredPorts") as? MGLShapeSource else {
            return
        }
        
        guard sender.state == .ended else {
            return
        }
        
        showPopup(false, animated: false)
        
        let point = sender.location(in: sender.view)
        let width = icon.size.width
        let rect = CGRect(x: point.x - width / 2, y: point.y - width / 2, width: width, height: width)
        
        let features = mapView.visibleFeatures(in: rect, styleLayerIdentifiers: ["clusteredPorts", "ports"])
        
        // Pick the first feature (which may be a port or a cluster), ideally selecting
        // the one nearest nearest one to the touch point.
        guard let feature = features.first else {
            return
        }
        
        let description: String
        let color: UIColor
        
        if let cluster = feature as? MGLPointFeatureCluster {
            // Tapped on a cluster.
            let children = source.children(of: cluster)

            description = "Folded \(children.count) Areas"
            color = .blue
        } else if let featureName = feature.attribute(forKey: "sr_subunit") as? String?,
            // Tapped on a port.

            let portName = featureName {
             let sampleReport:Report = userdata_.get_report(country: portName)
            
            description = "\(portName) \nConfirmed : \(sampleReport.total_confirmed)\nRecovered : \(sampleReport.total_recovered)\nDeath : \(sampleReport.total_deaths)"

            color = .black
        } else {
            // Tapped on a port that is missing a name.
            description = "No port name"
            color = .red
        }
        
        popup = popup(at: feature.coordinate, with: description, textColor: color)
        
        showPopup(true, animated: true)
    }
    
    // Convenience method to create a reusable popup view.
    private func popup(at coordinate: CLLocationCoordinate2D, with description: String, textColor: UIColor) -> UIView {
        let popup = UILabel()
        
        popup.backgroundColor     = UIColor.white.withAlphaComponent(0.9)
        popup.layer.cornerRadius  = 4
        popup.layer.masksToBounds = true
        popup.textAlignment       = .center
        popup.lineBreakMode       = .byTruncatingTail
        popup.numberOfLines       = 0
        popup.font                = .systemFont(ofSize: 16)
        popup.textColor           = textColor
        popup.alpha               = 0
        popup.text                = description
        popup.sizeToFit()
        
        // Expand the popup.
        popup.bounds = popup.bounds.insetBy(dx: -10, dy: -10)
        let point = mapView.convert(coordinate, toPointTo: mapView)
        popup.center = CGPoint(x: point.x, y: point.y - 50)
        
        return popup
    }
    
    func showPopup(_ shouldShow: Bool, animated: Bool) {
        guard let popup = self.popup else {
            return
        }
        
        if shouldShow {
            view.addSubview(popup)
        }
        
        let alpha: CGFloat = (shouldShow ? 1 : 0)
        
        let animation = {
            popup.alpha = alpha
        }
        
        let completion = { (_: Bool) in
            if !shouldShow {
                popup.removeFromSuperview()
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, animations: animation, completion: completion)
        } else {
            animation()
            completion(true)
        }
    }
    

    internal func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //Tab bar navigation button action
        
        if item.title == "Ranking"{
            self.performSegue(withIdentifier: "toRank", sender: self)
        }
        else if item.title == "Search"{
            self.performSegue(withIdentifier: "toSearch", sender: self)
        }
        else if item.title == "Home"{
            self.performSegue(withIdentifier: "toHome", sender: self)
        }
    }
}
extension ViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // This will only get called for the custom double tap gesture,
        // that should always be recognized simultaneously.
        return true
    }
}
