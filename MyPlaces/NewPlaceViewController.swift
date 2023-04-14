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
    
    // флаг загрузки изображения
    var imageIsChanged = false

    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        //загрузка в фоновом потоке объектов из массива
        DispatchQueue.main.async {
            self.newPlace.savePlaces()
        }
         */
//убирает строки/линии, где нет контента
        tableView.tableFooterView = UIView()
        
        // Отключение кнопки Save до заполнения обязательных полей
        saveButton.isEnabled = false
        // для отслеживания заполненных полей для кнопки save
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
 
//MARK: Table view delegdte
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
    
    //работа с кнопкой Save, логика кнопки
    func saveNewPlace() {
        
        
        
        
        // если изображение ресторана не изменено пользователем 
        var image: UIImage?
        if imageIsChanged {
            image = placeImage.image
        } else {
            image = UIImage(named: "defaultImage")
        }
        
        // конвертация изображения в тип Data
        let imageData = image?.pngData()
        
        let newPlace = Place(name: placeName.text!, location: placeLocation.text, type: placeType.text, imageData: imageData)
        
        // сохранение нового места в базе данных
        StorageManager.saveObject(newPlace)
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
