//
//  TableViewController.swift
//  MyPlaces
//
//  Created by Роза Шархмуллина on 22.02.23.
//

import UIKit
import RealmSwift

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // добавим экземпляр UISearchController для дольнейших действий (nil - для отображения результатов поиска хотим использовать тот же view, в котором отображается основной контент
    let searchController = UISearchController(searchResultsController: nil)
    //Results - это автообновляемый тип контейнера, который возвращает запрашиваемы объекты ( в текущем потоке)
    private var places: Results<Place>!
    // объявим новый массив для отсортированного массива
    private var filteredPlaces: Results<Place>!
        // объявим новое вспомогательное свойство для изменения направления сортировки
    private var ascendingSorting = true
    //является ли строка поиска пустым
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    //отслеживание активирования поисковой строки
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet var tableView: UITableView!
    //Для того, чтобы прикрепить SegmentedControl на navigationBar, необходимо tableVC исправить на обычный ViewController
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var reversedSortingButton: UIBarButtonItem!
    

    //var restaurantNames = ["Alaverdi", "Kiziki", "Tavaduri", "Chacha time", "Provence Cafe", "Place Batumi", "Bericoni", "Mary's Irish Pub"]
    // var places = Place.getPlaces()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Отоборажение элементов на экране
        places = realm.objects(Place.self)
        
        // Setup the searchController (получателем изменений является сам класс)
        searchController.searchResultsUpdater = self
        // взаимодействие с ViewController как с основным
        searchController.obscuresBackgroundDuringPresentation = false
            //название для строки поиска
        searchController.searchBar.placeholder = "Search"
        // поиск будет интегрирован в navigationBar
        navigationItem.searchController = searchController
        //  позволяет отпусти строку поиска при переходе на другой экран
        definesPresentationContext = true
        
        
    
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
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         //добавим условия для отфильтрованного массива
         if isFiltering {
             return filteredPlaces.count
         }
         return places.isEmpty ? 0 : places.count
    }
    
    
        // обязательный метод. Работаем над конфигурацией ячейки.
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Приведение объекта Cell к классу as
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        var place = Place()
        if isFiltering {
             place = filteredPlaces[indexPath.row]
        } else {
             place = places[indexPath.row]
        }
        //let place = places[indexPath.row]
        
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
         
        let raiting = String(place.rating)
        cell.ratingMainController.text = raiting
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
    
    
    //отмена выделения ячейки после редактирования
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //Удаление объекта
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let place = places[indexPath.row]
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    /*
     // Удаление объекта (второй способ) - более сложный
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
       
    // переход на экран редактирования записей
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            //Определяем индекс выбранной ячейки, которую нужно отредактировать
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            //извлекаем объект из массива places
            //let place = places[indexPath.row]
            //исправляем баг редактирования элементов в отсортированном массиве через поиск
            let place: Place
            if isFiltering {
                place = filteredPlaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
            //создаем экземпляр класса NewPlaceVC
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
       

        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
  

    //  save button activation
    @IBAction func unWingSegue(_ segue: UIStoryboardSegue) {
        //создаем экземпляр класса Place
        // возврат осуществляется через unwindSegue, source
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        
        newPlaceVC.savePlace()
        
        //Новые объекты сейчас сразу сохраняются в базе, соответсвенно необходимо прописать логику, при которой эти данные будут отображаться через базу
       //  places.append(newPlaceVC.newPlace!)
        // обновление интерфейса
        tableView.reloadData()
    }
    
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        //если пользователем выбрана сортировка по дате (SegmentedControl - date) и наоборот.
       sorting()
    }
    
    @IBAction func reversedSorting(_ sender: UIBarButtonItem) {
        //меняем сортировку на противоположное направление
        ascendingSorting.toggle()
        
        // изменение изображения
        if ascendingSorting {
            reversedSortingButton.image = UIImage(named: "AZ")
            
        } else {
            reversedSortingButton.image = UIImage(named: "ZA")
        }
        sorting()
    }
    
    // метод для сортировки
    private func sorting() {
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        //обновление таблицы
        tableView.reloadData()
    }
}


    // добавим расширение для работы с UISearchController
extension TableViewController: UISearchResultsUpdating {
    //обязательный метод
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        
    }
    
    //объявим метод, который будет заниматься фильтрацией под определенный поиск
    private func filterContentForSearchText(_ searchText: String) {
        //[c] - производит поиск в независимости от регистра
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
}
