//
//  searchViewController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/15.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    
    @IBOutlet weak var typeTF: UITextField!
    @IBOutlet weak var levelTF: UITextField!
    @IBOutlet weak var timeTF: UITextField!
    @IBOutlet weak var placeTF: UITextField!

    @IBAction func backButton(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    
    @IBAction func sureButton(_ sender: Any) {
        guard let type = typeTF.text,
            let level = levelTF.text,
            let city = placeTF.text,
            let time = timeTF.text else {
            return
        }
        
        mainViewController?.selectedPreference = Preference(type: type, level: Level(rawValue: level), place: city, time: time)
        self.view.removeFromSuperview()
    }
    
    var mainViewController: ListsController?
    
    var level: [Level] = [.A, .B, .C, .D]
    
    var selectedType: String?
    var selectedLevel: String?
    var selectedPlace: String?
    var selectedTime: String?
    
    var typePicker = UIPickerView()
    var levelPicker = UIPickerView()
    var timePicker = UIPickerView()
    var placePicker = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerDelegate()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        typeTF.inputView = typePicker
        levelTF.inputView = levelPicker
        timeTF.inputView = timePicker
        placeTF.inputView = placePicker
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView {
        case typePicker: return typeArray.count
        case levelPicker : return level.count
        case timePicker: return time.count
        case placePicker: return city.count
        default: return 1
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case typePicker: return typeArray[row]
        case levelPicker : return level[row].rawValue
        case timePicker: return time[row]
        case placePicker: return city[row]
        default: return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case typePicker:
            typeTF.text = typeArray[row]
            self.selectedType = typeArray[row]
        case levelPicker :
            levelTF.text = level[row].rawValue
            self.selectedLevel = level[row].rawValue
        case timePicker:
            timeTF.text = time[row]
            self.selectedTime = time[row]
        case placePicker:
            placeTF.text = city[row]
            self.selectedPlace = city[row]
        default: break
        }
    }
    
    typealias ShowAlertDismissHandler = () -> Void
    
    func showAlert(title: String?, message: String?, dismiss handler: ShowAlertDismissHandler?) {
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let ok = UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .cancel,
            handler: { _ in handler?() }
        )
        
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
        
    }
}

extension SearchViewController {
    
    func pickerDelegate() {
        typePicker.delegate = self
        typePicker.dataSource = self
        levelPicker.delegate = self
        levelPicker.dataSource = self
        placePicker.delegate = self
        placePicker.dataSource = self
        timePicker.delegate = self
        timePicker.dataSource = self
    }  
}

