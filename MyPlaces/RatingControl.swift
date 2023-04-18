//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Роза Шархмуллина on 18.04.23.
//

import UIKit
//@IBDesignable - позволяет отобразить контент, которым мы наполнили StackView в интерфейс builder
//@IBInspectable - позволяет отобрадить все свойста, которым мы наполнили StackView в интерфейс builder (типы нужно указывать явно)

@IBDesignable class RatingControl: UIStackView {
    
    // MARK: Properties
    
    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    
    private var ratingButtons = [UIButton]()
    // Объявим новые свойства, которые будут отвечать за количество звезд в StackView и за размеры кнопок
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    //quantity of stars
    @IBInspectable var starCount: Int = 5 {
        didSet {
            // add buttons (к нынешнему количеству)
            setupButtons()
        }
    }
    

    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    //обязательный инициализатор (при реализации в подклассе)
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    //MARK: button Actiob
    @objc func ratingButtonTapped(button: UIButton) {
        // определяем индекс кнопки, которой касается пользователь
        guard let index = ratingButtons.firstIndex(of: button) else { return }
        //Calculate the rating of the selected button
        
        let selectedRating = index + 1
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
        
    }
    
//добавим горизонтальный  StackView через storyboard
    // MARK: private methods
    // добавление кнопок в StackView
    private func setupButtons() {
        
        //удаление старых кнопок.
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingButtons.removeAll()
        
        //объявим свойчтво зля каждого типа звезды Load button image
        //метод bundle определяет местоположение ресурсов, которые хранятся в assets
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        // compatibleWith: self.traitCollection - загружен ли правильный вариант изображения
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        // creating 5 buttons
        for _ in 1...starCount {
            let button  = UIButton()
            //Set the button image
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            //при создании кнопки таким способом используется инициализатор frame, который создает прямоугольник нулевого размера.
            
                // Add constraints
            //отключение автоматически сгенерированных констрейнтов для кнопки. StackView автоматически устанавливает это значение в false
            button.translatesAutoresizingMaskIntoConstraints = false
            // определение высоты и ширины кнопки. метод isActive - активирует/деактивирует констрейнты
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            //Setup the button action
            button.addTarget(self, action: #selector(ratingButtonTapped(button: )), for: .touchUpInside)
            
            // Add button to the StackView
            addArrangedSubview(button)
            
            //Add the new button on the rating button Array
            ratingButtons.append(button)
            
        }
        
        updateButtonSelectionState()
    }
    // Обновление внешнего вида звезд в соответсвтии с рейтингом
    private func updateButtonSelectionState() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
}
