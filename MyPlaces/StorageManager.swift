//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Роза Шархмуллина on 14.04.23.
//

import RealmSwift

//создаем объект Realm
let realm = try! Realm()

class StorageManager {
    
    // реализация метода для сохраниния объектов типа Place
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
}
