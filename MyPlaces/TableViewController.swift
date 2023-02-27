//
//  TableViewController.swift
//  MyPlaces
//
//  Created by Роза Шархмуллина on 22.02.23.
//

import UIKit

class TableViewController: UITableViewController {
    
    var restaurantNames = ["Alaverdi", "Kiziki", "Tavaduri", "Chacha time", "Provence Cafe", "Place Batumi", "Bericoni", "Mary's Irish Pub"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        return restaurantNames.count
    }
    
    
        // обязательный метод. Работаем над конфигурацией ячейки.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = restaurantNames[indexPath.row]
        // indexPath.row - возвращает целочисленное значение, равное индексу строки
        // присваеваем ячейке изображение.
        cell.imageView?.image = UIImage(named: restaurantNames[indexPath.row])
        return cell
    }
   

 
    // MARK: - Navigation
        /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
