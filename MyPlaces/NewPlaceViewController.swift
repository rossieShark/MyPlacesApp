//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Роза Шархмуллина on 28.02.23.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    //создаем новый экземпляр класса для сохранения новых значений
    //var newPlace = Place()
    //создаем объект для передачи на segue
    var currentPlace: Place!
    // флаг загрузки изображения
    var imageIsChanged = false

    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var placeName: UITextField!
    @IBOutlet var placeLocation: UITextField!
    @IBOutlet var placeType: UITextField!
    @IBOutlet var ratingControl: RatingControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        //загрузка в фоновом потоке объектов из массива
        DispatchQueue.main.async {
            self.newPlace.savePlaces()
        }
         */
//убирает строки/линии, где нет контента
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 1))
        
        // Отключение кнопки Save до заполнения обязательных полей
        saveButton.isEnabled = false
        // для отслеживания заполненных полей для кнопки save
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        //вызываем метод для редактирования записей, метод должен идти ниже метода для отключения кнопки ~~Save
        setupEditScreen()
    }
 
//MARK: Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            //добавление иконок к экшенам (создание)
            let cameraIcon = UIImage(named: "camera")
            let photoIcon = UIImage(named: "photo")
            
            //меню снизу экрана для вставки изображения
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            
            //прописываем действия
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseIMagePicker(source: .camera)
            }
            
            //добавление иконок к экшенам (добавление)
            camera.setValue(cameraIcon, forKey: "image")
            //установка текста слева
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseIMagePicker(source: .photoLibrary)
            }
            
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    
    //MARK: Navigation (переход к MapVC)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //попробуем извлесь идентифаер
        guard let identifier = segue.identifier,
                let mapVC = segue.destination as? MapViewController else { return }
        mapVC.incomeSegueIdentifier = identifier
        //назначим делегата
        mapVC.mapViewControllerDelegate = self

        //создаем экземпляр типа MapVC
        //let mapVC = segue.destination as! MapViewController
        if identifier == "showPlace" {
            //передаем значения из полей
            mapVC.place.name = placeName.text!
            mapVC.place.location = placeLocation.text
            mapVC.place.type = placeType.text
            mapVC.place.imageData = placeImage.image?.pngData()
        
        }
    }
    
    
    //работа с кнопкой Save, логика кнопки
    func savePlace() {
        
        // если изображение ресторана не изменено пользователем
        /*
        var image: UIImage?
        if imageIsChanged {
            image = placeImage.image
        } else {
            image = UIImage(named: "defaultImage")
        }
        */
        let image = imageIsChanged ? placeImage.image : UIImage(named: "defaultImage")
        // конвертация изображения в тип Data
        let imageData = image?.pngData()
        
        let newPlace = Place(name: placeName.text!, location: placeLocation.text, type: placeType.text, imageData: imageData, rating: Double(ratingControl.rating))
        //определяем режим редактирования: добавление новой записи или же анесение изменений
        if currentPlace != nil {
            try! realm.write() {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        } else {
            // сохранение нового места в базе данных
            StorageManager.saveObject(newPlace)
        }
    }
    
    // создадим приватный метод для редактирования записей
    private func setupEditScreen() {
        if currentPlace != nil {
            //вызываем метод изменения NavigationBar только в случае редактирования
            setupNavigationBar()
            imageIsChanged = true
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            
            placeImage.image = image
            //изображение отображается некорректно, чтобы это исправить (слишком расширенное)
            placeImage.contentMode = .scaleAspectFill
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            ratingControl.rating = Int(currentPlace.rating)
        }
    }
    
    //работа над navigationBar в окне редактирования
    private func setupNavigationBar() {
        //в кнопке назад оставим только стрелку
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        //уберем кнопку "Cancel"
        navigationItem.leftBarButtonItem = nil
        //поменяем название шапки окна на текушее название заведения выбранной ячейки
        title = currentPlace?.name
        //делаем кнопку "Save" всегда доступной
        saveButton.isEnabled = true
    }
//логика кнопки cancel
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

//MARK: Text field delegate
extension NewPlaceViewController: UITextFieldDelegate {
    //Скрываем клавиатуру по нажатию на Done
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
        // проверка изменения текста
    @objc private func textFieldChanged() {
        // если поле не пустое ..
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    

}
 

//MARK: Work with image (Image Picker)
extension NewPlaceViewController: UIImagePickerControllerDelegate,  UINavigationControllerDelegate {
    
    func chooseIMagePicker(source: UIImagePickerController.SourceType) {
        //проверка на доступность выбора изображений
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            //делегация
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            
            //отображение на экране
            present(imagePicker, animated: true, completion: nil)
        }
        
    }
    //метод, позволяющий добавить изображение, выбранное с фото на экран
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        // обрезка по границе
        placeImage.clipsToBounds = true
        
        imageIsChanged = true
        //закрываем Imagepicker
        dismiss(animated: true)
    }
}

extension NewPlaceViewController: MapViewControllerDelegate {
   
    func getAddress(_ address: String?) {
        placeLocation.text = address
    }
    
    
}
