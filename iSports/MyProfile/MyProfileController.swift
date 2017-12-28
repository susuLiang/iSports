//
//  MyProfileController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/21.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift
import SkyFloatingLabelTextField
import Fusuma
import SCLAlertView
import Nuke


class MyProfileController: UIViewController, UITextFieldDelegate, FusumaDelegate, UITableViewDelegate, UITableViewDataSource {
   
    let keyChain = KeychainSwift()
    
    let fusuma = FusumaViewController()
    
    var userImage = UIImage()
    
    var userSetting: UserSetting? = nil
    
    var settingType = ["Profile", "Preference"]
    
    var settingIconName = ["profile-user", "profile-setting"]
    
    var isExpanded = false
    
    var selectedIndex = -1
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var pickPhotoButton: UIButton!
    @IBAction func logOut(_ sender: Any) {
        let alertController = UIAlertController(title: "Log out", message: "Be sure to log out?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Sure", style: .default, handler: { (action) in
            self.keyChain.clear()
            do {
                try Auth.auth().signOut()
            } catch let logoutError {
                print(logoutError)
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginController = storyboard.instantiateViewController(withIdentifier: "loginController")
            self.present(loginController, animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func pickPhoto(_ sender: Any) {
        self.present(fusuma, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserProfile()
        
        setupTableCell()
        
        fusuma.delegate = self
        fusuma.cropHeightRatio = 0.6
        
        setNavigationBar()
        setLogOutButton()
    
        pickPhotoButton.isEnabled = false
        
        nameLabel.text = keyChain.get("name")
        userPhoto.layer.cornerRadius = 100
        userPhoto.clipsToBounds = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getUserProfile() {
        FirebaseProvider.shared.getUserProfile(completion: { (userSetting, error) in
            if error == nil {
                self.userSetting = userSetting
                self.nameLabel.text = self.userSetting?.name
                if userSetting?.urlString != nil {
                    Nuke.loadImage(with: URL(string: (self.userSetting?.urlString)!)!, into: self.userPhoto)
                    self.userPhoto.contentMode = .scaleAspectFill
                }
            }
        })
    }
    
    func loadUserPhoto() {
        Nuke.loadImage(with: URL(string: (self.userSetting?.urlString)!)!, into: self.userPhoto)
        self.userPhoto.contentMode = .scaleAspectFill
    }
    
    
    @objc func showBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func setLogOutButton() {
        logOutButton.layer.cornerRadius = 20
        logOutButton.layer.shadowRadius = 5
    }
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        userPhoto.image = image
        self.userImage = image
        userPhoto.contentMode = .scaleAspectFill
    }
    
    @objc func edit() {
        let saveIcon = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-save"), style: .plain, target: self, action: #selector(showAlert))
        navigationItem.rightBarButtonItem = saveIcon
        pickPhotoButton.isEnabled = true
    }
    
    @objc func showAlert() {
        let editIt = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-edit"), style: .plain, target: self, action: #selector(edit))
        navigationItem.rightBarButtonItem = editIt
        pickPhotoButton.isEnabled = false
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("SURE", action: self.saveIt)
        alertView.addButton("NO") {
        }
        alertView.showWarning("Sure to save it ?", subTitle: "")
    }
    
    func saveIt() {
        
        guard let userUid = keyChain.get("uid") else { return }
        
        var data = Data()
        
        data = UIImageJPEGRepresentation(userPhoto.image!, 0.6)!
        
        let ref = Database.database().reference()
        
        let storageRef = Storage.storage().reference()
        
        let metadata = StorageMetadata()
        
        
        metadata.contentType = "image/jpg"
        
        storageRef.child(userUid).putData(data,metadata: metadata) { (metadata, error) in
            
            guard let metadata = metadata else {
                
                // Todo: error handling
                
                return
            }
            
            let downloadURL = metadata.downloadURL()?.absoluteString
            
            let value = ["imageURL": downloadURL]

            ref.child("users").child(userUid).updateChildValues(value)
        
        }
        
    }
    
    func setupTableCell() {
        let nib = UINib(nibName: "MyProfileCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingType.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MyProfileCell else {
            fatalError("Invalid profile cell") }
        cell.cellLabel?.text = settingType[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        cell.cellLabel?.font = UIFont(name: "ArialHebrew-Bold", size: 18)
        cell.lableImage?.image = UIImage(named: "\(settingIconName[indexPath.row])")
        
        if indexPath.row == 1 && isExpanded {
            cell.preferenceView.isHidden = false
            cell.typeSettingTextField.text = self.userSetting?.preference.type
            cell.levelSettingTextField.text = self.userSetting?.preference.level?.rawValue
            cell.citySettingTextField.text = self.userSetting?.preference.place
            cell.timeSettingTextField.text = self.userSetting?.preference.time
        } else if indexPath.row == 0 && isExpanded {
            cell.profileView.isHidden = false
            cell.nameSettimgTextField.text = self.userSetting?.name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isExpanded && self.selectedIndex == indexPath.row {
            return 192
        }
        else {
            return 68
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.isExpanded = !isExpanded
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        self.tableView.endUpdates()
    }
    
    func setNavigationBar() {
        let myProfile = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-menu"), style: .plain, target: self, action: #selector(showBack))
        let editIt = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-edit"), style: .plain, target: self, action: #selector(edit))
        navigationItem.leftBarButtonItems = [myProfile]
        navigationItem.rightBarButtonItem = editIt
    }
    
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
    }
    
    func fusumaCameraRollUnauthorized() {
    }

}
