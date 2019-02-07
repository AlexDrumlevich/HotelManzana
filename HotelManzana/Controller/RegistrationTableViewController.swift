//
//  RegistrationTableViewController.swift
//  HotelManzana
//
//  Created by Друмлевич on 05.02.2019.
//  Copyright © 2019 Alexey Drumlevich. All rights reserved.
//

import UIKit
import MessageUI

class RegistrationTableViewController: UITableViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var eMailTextField: UITextField!
    
    @IBOutlet weak var checkInDateLabel: UILabel!
    @IBOutlet weak var checkInDatePicker: UIDatePicker!
    @IBOutlet weak var checkOutDateLabel: UILabel!
    @IBOutlet weak var checkOutDatePicker: UIDatePicker!
    
    @IBOutlet weak var wiFiImageView: UIImageView!
    
    @IBOutlet weak var wifiButtonOutlet: UIButton!
    @IBOutlet weak var wifiLabel: UILabel!
    
    
    @IBOutlet weak var adultsLabel: UILabel!
    
    @IBOutlet weak var childrenLabel: UILabel!
    
    @IBOutlet var stepperAdultsAndChildrenOutlet: [UIStepper]!
    
    @IBOutlet weak var roomLabel: UILabel!
    
    
    let checkInDateLabelIndexPath = IndexPath(row: 0, section: 1)
    let checkInDatePickerIndexPath = IndexPath(row: 1, section: 1)
    let checkOutDateLabelIndexPath = IndexPath(row: 2, section: 1)
    let checkOutDatePickerIndexPath = IndexPath(row: 3, section: 1)
    
    var isCheckInDatePickerShown: Bool = false {
        didSet {
            checkInDatePicker.isHidden = !isCheckInDatePickerShown
        }
    }
    var isCheckOutDatePickerShown: Bool = false {
        didSet {
            checkOutDatePicker.isHidden = !isCheckOutDatePickerShown
        }
    }
    
    var wiFi = false
    var countOfAdults = 0
    var countOfChildren = 0
    var firstResponder: UITextField?
    var roomType: RoomType?
    var stringOfErrors = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let midnightToday = Calendar.current.startOfDay(for: Date())
        checkInDatePicker.minimumDate = midnightToday
        checkInDatePicker.date = midnightToday
        setWiFiImage()
        updateDateViews()
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        eMailTextField.delegate = self
        eMailTextField.keyboardType = .emailAddress
        for value in stepperAdultsAndChildrenOutlet {
            value.minimumValue = 0
            value.stepValue = 1
        }
    }
    
    
    func updateDateViews() {
        checkOutDatePicker.minimumDate = checkInDatePicker.date.addingTimeInterval(24 * 60 * 60)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        checkInDateLabel.text = dateFormatter.string(from: checkInDatePicker.date)
        checkOutDateLabel.text = dateFormatter.string(from: checkOutDatePicker.date)
    }
    
    func setWiFiImage(){
        if wiFi {
            guard let image = UIImage(named: "wifi") else {return}
            wiFiImageView.image = image
            wifiLabel.text = "with WiFi"
        } else {
            guard let image = UIImage(named: "nowifi") else {return}
            wiFiImageView.image = image
            wifiLabel.text = "with out WiFi"
        }
    }
    
    func resignTextViewFirstResponder() {
        if let firstResponder = firstResponder {
            if firstResponder.isFirstResponder {
                firstResponder.resignFirstResponder()
                self.firstResponder = nil
            }
        }
    }
    
    func mail(text: String) {
        guard MFMailComposeViewController.canSendMail() else {
            alertController(text: "Can't send mail")
            return
        }
        let controller = MFMailComposeViewController()
        //controller.mailComposeDelegate = self
        controller.mailComposeDelegate = self
        controller.setMessageBody(text, isHTML: false)
        controller.setSubject("Room oder")
        controller.setToRecipients(["l-gc@yandex.ru"])
        present(controller, animated:  true, completion: nil)
    }
    
    func alertController(text: String) {
        let alertController = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancel)
        present(alertController, animated:  true, completion:  nil)
    }
    
    @IBAction func unwind(_ unwindSegue: UIStoryboardSegue) {
        if let sourceViewController = unwindSegue.source as? RoomTableViewController {
            roomType = sourceViewController.roomType
            if let roomType = roomType {
                roomLabel.text = roomType.shortName + "    " + String(roomType.price) + "$"
            }
        }
        
        
        // Use data from the view controller which initiated the unwind segue
    }
    
    
    @IBAction func buttonPressed() {
        resignTextViewFirstResponder()
        
        var firstName = String()
        var lastName = String()
        var email = String()
        let checkInDate = checkInDatePicker.date
        let checkOutDate = checkOutDatePicker.date
        let adults = countOfAdults
        let children = countOfChildren
        var room: RoomType?
        
        if let firstNameCheck = firstNameTextField.text {
            if firstNameCheck == "" {
                stringOfErrors += "first name has not been entered \n"
            } else {firstName = firstNameCheck}
        } else {stringOfErrors += "first name has not been entered \n"}
        
        if let lastNameCheck = lastNameTextField.text {
            if lastNameCheck == "" {
                stringOfErrors += "last name has not been entered \n"
            } else {lastName = lastNameCheck}
        } else {stringOfErrors += "last name has not been entered \n"}
        
        
        if let emailCheck = eMailTextField.text {
            if emailCheck == "" {
                stringOfErrors += "e-mail has not been entered \n"
            } else {email = emailCheck}
        } else {stringOfErrors += "e-mail has not been entered \n"}
        
        if adults == 0 && children == 0 {
            stringOfErrors += "count of guests has not been entered \n"
        } else if adults == 0 && children > 0 {
            stringOfErrors += "children can`t live independently \n"
        }
        
        if roomType == nil {
            stringOfErrors += "room has not been chousen  \n"
        } else {
            room = roomType!
        }
        
        if stringOfErrors != "" {
            let alertController = UIAlertController(title: "Error", message: stringOfErrors, preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(ok)
            present(alertController, animated:  true, completion: nil)
            stringOfErrors = ""
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let registration = Registration(
            firstName: firstName,
            lastName: lastName,
            emailAddress: email,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            numberOfAdults: adults,
            numberOfChildren: children,
            roomType: RoomType(
                id: (room?.id)!,
                name: (room?.name)!,
                shortName: (room?.shortName)!,
                price: (room?.price)!
            ),
            wifi: wiFi
        )
        
        let text = """
        My oder:
        Name: \(registration.firstName)
        Last name: \(registration.lastName)
        e-mail: \(registration.emailAddress)
        check in date: \(dateFormatter.string(from: registration.checkInDate))
        check out date: \(dateFormatter.string(from: registration.checkOutDate))
        adults: \(String(registration.numberOfAdults))
        children: \(String(registration.numberOfChildren))
        room: \(registration.roomType.name) \(String(registration.roomType.price))$
        wifi \(registration.wifi)
        
        """
        mail(text: text)
        
        print(#function, registration)
    }
    
    
    @IBAction func dataPickerChangeVlue(_ sender: UIDatePicker) {
        resignTextViewFirstResponder()
        updateDateViews()
    }
    
    
    @IBAction func datePickerCheckInTouchtUpInside(_ sender: UIButton) {
        resignTextViewFirstResponder()
        isCheckInDatePickerShown = !isCheckInDatePickerShown
        tableView.beginUpdates()
        tableView.endUpdates()
        
    }
    @IBAction func datePickerCheckOutTouchtUpInside(_ sender: UIButton) {
        resignTextViewFirstResponder()
        isCheckOutDatePickerShown = !isCheckOutDatePickerShown
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func wiFiActionButton(_ sender: UIButton) {
        resignTextViewFirstResponder()
        print("hello")
        wiFi = !wiFi
        setWiFiImage()
    }
    
    @IBAction func adultsStepperChangeValue(_ sender: UIStepper) {
        resignTextViewFirstResponder()
        countOfAdults = Int(sender.value)
        adultsLabel.text = String(countOfAdults)
    }
    
    @IBAction func childrenStepperChangeValue(_ sender: UIStepper) {
        resignTextViewFirstResponder()
        countOfChildren = Int(sender.value)
        childrenLabel.text = String(countOfChildren)
    }
    
    
}




// MARK: - ... UITableViewDelegate
extension RegistrationTableViewController /*: UITableViewDelegate*/ {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath {
        case checkInDatePickerIndexPath:
            return isCheckInDatePickerShown ? 216 : 0
        case checkInDateLabelIndexPath:
            return isCheckInDatePickerShown ? 0 : 44
        case checkOutDatePickerIndexPath:
            return isCheckOutDatePickerShown ? 216 : 0
        case checkOutDateLabelIndexPath:
            return isCheckOutDatePickerShown ? 0 : 44
        default:
            return 44
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        resignTextViewFirstResponder()
        
        switch indexPath {
        case checkInDateLabelIndexPath:
            isCheckInDatePickerShown = !isCheckInDatePickerShown
            if isCheckOutDatePickerShown {
                isCheckOutDatePickerShown = !isCheckOutDatePickerShown
            }
        case checkOutDateLabelIndexPath:
            isCheckOutDatePickerShown = !isCheckOutDatePickerShown
            if isCheckInDatePickerShown {
                isCheckInDatePickerShown = !isCheckInDatePickerShown
            }
        default:
            break
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

extension RegistrationTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        firstResponder = textField
        return true
    }
    
    
}

extension RegistrationTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        switch result {
        case .sent:
            alertController(text: "Your order has been sended!")
        default:
            alertController(text: "Your order has not been sended!")
        }
    }
}

