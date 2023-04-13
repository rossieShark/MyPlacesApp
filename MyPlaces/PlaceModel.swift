//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Роза Шархмуллина on 27.02.23.
//

import UIKit
// в качестве модели данных обычно используют Структуры
struct Place {
    var name: String
    var location: String?
    var type: String?
    var image: UIImage?
        // изменение названия переменной на все проекте - refactor -> rename
    var restaurantImage: String?
    
    static let restaurantNames = ["Alaverdi", "Kiziki", "Tavaduri", "Chacha time", "Provence Cafe", "Place Batumi", "Bericoni", "Mary's Irish Pub"]
    
    
    // Напишем функцию, которая будет автоматически генерировать названия мест
    
   static func getPlaces() -> [Place] {
        var places = [Place]()
        for place in restaurantNames {
            places.append(Place(name: place, location: "Batumi", type: "Restaurant",image: nil, restaurantImage: place))
        }
        
        
        return places
    }
}


