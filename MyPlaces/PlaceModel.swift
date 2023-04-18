//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Роза Шархмуллина on 27.02.23.
//

import RealmSwift
// в качестве модели данных обычно используют Структуры
class Place: Object {
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?   //меняем название параметра и тип с UIImage на Data
    @objc dynamic var date = Date() // переменная для сортировки по дате, для внутреннего использования
    @objc dynamic var rating = 0.0 
    
    // convenience - назначенный инициализатор (необязательный)
    convenience init(name: String, location: String?, type: String?, imageData: Data?, rating: Double) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.rating = rating
    }
    
    
    
    
    // загрузка временного массива
    /*
        // изменение названия переменной на все проекте - refactor -> rename
    //var restaurantImage: String?
    
    let restaurantNames = ["Alaverdi", "Kiziki", "Tavaduri", "Chacha time", "Provence Cafe", "Place Batumi", "Bericoni", "Mary's Irish Pub"]
    
    
    // Напишем функцию, которая будет автоматически генерировать названия мест
    
   func savePlaces() {
        //var places = [Place]()
        for place in restaurantNames {
            
            let image = UIImage(named: place)
            //Мееняем тип данных image с UIImage в Data
            guard let imageData = image?.pngData() else { return }
            let newPlace = Place()
            newPlace.name = place
            newPlace.location = "Batumi"
            newPlace.type = "Restaurant"
            newPlace.imageData = imageData
            
            StorageManager.saveObject(newPlace)
            
            // При работе с Realm уже не понадобится:
            //places.append(Place(name: place, location: "Batumi", type: "Restaurant",image: nil, restaurantImage: place))
        }
        
        
        //return places
    }
     */
}


