//
//  mapViewController.swift
//  MyPlaces
//
//  Created by Роза Шархмуллина on 25.04.23.
//

import UIKit
import MapKit //для работы с картами
import CoreLocation //для определения местоположения пользователя
//передача выбранной области в поле location

protocol MapViewControllerDelegate {
    // протоколы не реализуют методы, а лишь описывают их
    //необязательные методы нужно пометить как @objc optional и сам протокол
    func getAddress(_ address: String?)
}
//также необязательным можно сделать через расширение
    /*
extension MapViewControllerDelegate {
    func
}
     */
class MapViewController: UIViewController {
    var mapViewControllerDelegate: MapViewControllerDelegate?
    
    //объявим новое свойство типа Place
    
    var place = Place()
    
    //объявим новое свойство класса, которое содержит в себе идентификатор
    var annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 1000
    //свойство, которое будет передавать идентификатор (В зависимости от перехода)
    var incomeSegueIdentifier = ""

    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = ""
        //назначим делегата
        mapView.delegate = self
        setupMapView()
        checkLocationServices()

        // Do any additional setup after loading the view.
    }

// кнопка, которая на карте показывает местоположение юзера
    @IBAction func centerViewInUserLocation() {
        showUserLocation()
    }
    
    @IBAction func doneButtonPressed() {
        //передаем текущее значение адреса
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        //закрываем ViewController
        dismiss(animated: true)
    }
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    private func setupMapView() {
        if incomeSegueIdentifier == "showPlace" {
            setupPlaceMark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
        }
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
    //необходимо убедиться, что у пользователя включены настройки по разрешению определения геолокации
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            //если службы геолокации доступны
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.alertControl(
                    title: "Location Services are Disabled",
                    message: "To enable it go: Settings -> Privacy -> Location Services and turn On")
            }
            
        }
    }
        // первоначальные установки свойства locationManager
    private func setupLocationManager() {
        locationManager.delegate = self
        //точность определения геолокации
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //лучшая точность
    }
    //проверка статуса на использование геопозиции
    private func checkLocationAuthorization() {
        //есть 5 статусов авторизации, необходимо обработать каждый из них
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: //приложению разрешено определять геолокацию в момент его использования
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getAddress" { showUserLocation() }
            break
        case .denied: //приложению отказывают в использовании геопозиции или же у пользователя в настойках стоит запрет
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.alertControl(
                    title: "Your location is not available",
                    message: "To give permission Go to: Setting -> MyPlaces -> Location")
            }
            break
        case .notDetermined: //статус неопределен ( пользователь еще не сделал выбор)
            locationManager.requestWhenInUseAuthorization()
        case .restricted: //приложение не авторизовано для использования служб геолокации
            
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is available")
        }
    }
    private func showUserLocation() {
        // проверим координаты пользователя, возможно ли определить
        if let location = locationManager.location?.coordinate {
            //определяем регион
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            //устанавливаем регион для отображения на экране
            mapView.setRegion(region, animated: true)
        }
    }
    
    //определение координат в центре отоброжаемой области карты
    private func getCenterLocation(for mavView: MKMapView) -> CLLocation {
        //широта
        let latitude = mavView.centerCoordinate.latitude
        //долгота
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    private func alertControl(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        let settingAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:] )
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingAction)
        
        self.present(alertController, animated: true, completion: nil)
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
    // данный метод будет вызываться при смене отоброжаемого региона, и отоброжать адрес по центру
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        //необходимо преоброзовать координаты в адрес
        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            if let  error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
                
                
            }
        }
        
    }
}
//чтобы была возможность отслеживать статус геопозиции в реальном времени
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
