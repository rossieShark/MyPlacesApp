//
//  TableViewController.swift
//  MyPlaces
//
//  Created by Роза Шархмуллина on 22.02.23.
//

import UIKit
import RealmSwift

class TableViewController: UITableViewController {
    
    //var restaurantNames = ["Alaverdi", "Kiziki", "Tavaduri", "Chacha time", "Provence Cafe", "Place Batumi", "Bericoni", "Mary's Irish Pub"]
    
    // var places = Place.getPlaces()
    
    //Results - это автообновляемый тип контейнера, который возвращает запрашиваемы объекты ( в текущем потоке)
    var places: Results<Place>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Отоборажение элементов на экране
        places = realm.objects(Place.self)
        
        
    }

    // MARK: - Table view data source
//возвращает кол-во секций (если в приложении всего 1 секция, то можно удалить)
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
*/
    
    //обязательный метод, возвращает количество ячеек (может быть 0)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }
    
    
        // обязательный метод. Работаем над конфигурацией ячейки.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Приведение объекта Cell к классу as
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let place = places[indexPath.row]
        
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        /*
            // В случае, если пользователь не загрузил изображение места, реализуем метод, который вставляет изображение по дефолту
        if place.image == nil {
            // присваеваем ячейке изображение.
            cell.imageOfPlace?.image = UIImage(named: place.restaurantImage!)
        } else {
            cell.imageOfPlace.image = place.image
        }
         */
        //  В случае с работой базой дынных, изображение не может быть nil.
        
        
        // indexPath.row - возвращает целочисленное значение, равное индексу строки
        // присваеваем ячейке изображение.
        
        //работа с изображением
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2 //закругление ImageView
        cell.imageOfPlace?.clipsToBounds = true //обрезка изображения
        return cell
    }
   
    
    //MARK: - Table View Delegate
    
    //Удаление объекта
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let place = places[indexPath.row]
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    /*
     // Удаление объекта (сторой способ) - более сложный
    //действия по свайпу справа налево (слева leading)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // создадим объект модели, который будем передавать методу deleteObject
        let place = places[indexPath.row]
        
        //удаляем из базы
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteObject(place)
        }
        
        //удаляем строку в самом приложение(на экране)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
     */
    /*
         //высота ячейки
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 85
        }
*/
 
    // MARK: - Navigation
        /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //  save button activation
    @IBAction func unWingSegue(_ segue: UIStoryboardSegue) {
        //создаем экземпляр класса Place
        // возврат осуществляется через unwindSegue, source
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        
        newPlaceVC.saveNewPlace()
        
        //Новые объекты сейчас сразу сохраняются в базе, соответсвенно необходимо прописать логику, при которой эти данные будут отображаться через базу
       //  places.append(newPlaceVC.newPlace!)
        // обновление интерфейса
        tableView.reloadData()
    }
}
