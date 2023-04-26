//
//  mapViewController.swift
//  MyPlaces
//
//  Created by Роза Шархмуллина on 25.04.23.
//

import UIKit
import MapKit //для работы с картами

class MapViewController: UIViewController {
    
    //объявим новое свойство типа Place
    
    var place = Place()
    
    //объявим новое свойство класса, которое содержит в себе идентификатор
    var annotationIdentifier = "annotationIdentifier"
    

    @IBOutlet var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlaceMark()
        //назначим делегата
        mapView.delegate = self

        // Do any additional setup after loading the view.
    }


    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    //работа над маркером, который будет обозначать место
    private func setupPlaceMark() {
        //сначала извлекаем адрес заведения
        guard let location = place.location else { return }
        //преобразование географ координат в географ названий.
        let geocoder = CLGeocoder()
        // позволяет определить местоположение на карте.
        geocoder.geocodeAddressString(location) { placemarks, error in
            //проверка на наличие ошибки
            if let error = error {
                print(error)
                return
            }
            //извлекаем опционал
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            // Используется для описания какой-либо точки на карте
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            //определяем местоположение маркера
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            //задаем видимую область карты таким образом, чтобы на ней были видны все созданные аннотации
            self.mapView.showAnnotations([annotation], animated: true)
            //выделение созданной аннотации
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
}
//для разворота аннотации нам необходимо подписаться под протокол MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    //отображение аннотации
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // сначала необходимо убедиться, что аннотация не является аннотацией, которая определяет текущее местонахождение пользователя
        guard !(annotation is MKUserLocation) else { return  nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        //если на карте нет ни одного представления с аннотацией, которое мы можем использовать
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            
            // отображение аннотации по типу баннера
            annotationView?.canShowCallout = true
        }
        //отобразим изображение баннера
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
}
