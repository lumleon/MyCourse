//
//  AddCourseViewController.swift
//  myCourse
//
//  Class to add course from the tableview to icloud private database. Advanced function is setup for iBeacon function which allow location based feature to save student course data to public database and query by studentid and beanname
//
//  Created by Leon Lum on 17/05/20.
//  Edited by Leon Lum, Kyle He on 17/06/15
//  Copyright © 2017 Extreme. All rights reserved.
//

import UIKit
import CloudKit
import Bean_iOS_OSX_SDK

class AddCourseViewController: UIViewController, PTDBeanDelegate, PTDBeanManagerDelegate {
    
  //  let myContainer = CKContainer.default()
    
    let myContainer = CKContainer(identifier: "iCloud.com.appglory.myCourse")
    
    var publicDB: CKDatabase!
    var privateDB: CKDatabase!
    
    let cloudstatus = CloudAccount.checkcloudlogin()
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //Define IBOutlet for course id and text
    @IBOutlet weak var courseIdTextField: UITextField!
    @IBOutlet weak var courseNameTextField: UITextField!
    
    //Define IBOutlet for Switch button
    @IBOutlet weak var advancedSwitch: UISwitch!
    @IBOutlet weak var textSwitch: UILabel!
    
    //Define IBOutlet for courseview
    @IBOutlet var addCourseView: UIView!
    
    //Define IBOutlet for studend id
    @IBOutlet weak var studentIdTextField: UITextField!
    
    //Define stackview for hide or unhide when   detecting bean
    @IBOutlet weak var studentInfo: UIStackView!
    
    //Define control for bean function
    @IBOutlet weak var BeanButton: UIButton!
    
    //Define Alert controller
    var alert: UIAlertController!
    
    //Define current CKrecord
    var currentRecord: CKRecord?
    
    //Define variables for beanmanager
    var beanManager: PTDBeanManager?
    
    //Define Bean object
    var yourBean: PTDBean?
    
    //Define beanname
    var beanName: String?
    
    //Define scan error
    var scanError: NSError?
    
    //  define userDefaults
    let userDefault = UserDefaults.standard
    
    //Define constant for user default of switching advaned function
    let switchKeyConstant = "AdvancedOnOff"
    let textAdvancedKeyConstant = "AdvancedText"
    let textAdvancedOnlabel = "Advanced mode is On"
    let textAdvancedOfflabel = "Advanced mode is Off"
    
    let message = "Sign in to your iCloud account to write records. On the Home screen, launch Settings, tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID."
    
    //MARK: function to load  after loading the view.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        publicDB  = myContainer.publicCloudDatabase
        privateDB = myContainer.privateCloudDatabase
        
        //Define imageview and set to background
        let imageView   = UIImageView(frame: self.view.bounds);
        imageView.image = UIImage(named: "footer_8.jpg")
        self.addCourseView.addSubview(imageView)
        self.addCourseView.sendSubview(toBack: imageView)
        
        if !cloudstatus.isEmpty {
            createAlert(title: "Attention", text: cloudstatus)
        }
            
        //START Beacon function setup
        studentInfo.isHidden = true
        
        //set initial label for switch text
        if let textFieldValue = userDefault.string(forKey: switchKeyConstant) {
            textSwitch.text = textFieldValue
        } else{
            textSwitch.text = textAdvancedOfflabel
        }
        
        //set status of switch text from userdefault value
        if (userDefault.bool(forKey: switchKeyConstant)) {
            advancedSwitch.isOn = true
            textSwitch.text = textAdvancedOnlabel
            
        } else {
            advancedSwitch.isOn = false
            textSwitch.text = textAdvancedOfflabel
        }
        
        //allow advanced function if switch is set on
        if  advancedSwitch.isOn {
            runAdvanced ()
        }
        //END Beacon function Setup
        
    }
    
    //MARK: function to start the iBeacon
    private func runAdvanced (){
        
        // Create instance of PTDBeanManager and assign as the delegate
        beanManager = PTDBeanManager()
        beanManager!.delegate = self as PTDBeanManagerDelegate
        
        //Define double tap gesture recognizer for Beanbutton to add record to cloudkit
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tapRecognizer.numberOfTapsRequired = 2
        BeanButton.addGestureRecognizer(tapRecognizer)
        
    }
    
    
    //MARK: function when switch button clicked
    @IBAction func clickSwitch(_ sender: UISwitch) {
        
        if advancedSwitch.isOn == true {
            
            //set value to false
            textSwitch.text = textAdvancedOfflabel
            advancedSwitch.isOn = false
            
            //hide student info stackview
            studentInfo.isHidden = true
            
            //update default value to false
            userDefault.setValue(textSwitch.text, forKey: textAdvancedKeyConstant)
            userDefault.set(advancedSwitch.isOn, forKey: switchKeyConstant)
            
            //set the switch
            advancedSwitch.setOn(false, animated:true)
            
        } else {
            //set value to false
            textSwitch.text = textAdvancedOnlabel
            advancedSwitch.isOn = true
            
            //update default value to true
            userDefault.setValue(textSwitch.text, forKey: textAdvancedKeyConstant)
            userDefault.set(advancedSwitch.isOn, forKey: switchKeyConstant)
            
            runAdvanced ()
            
            //set the switch
            advancedSwitch.setOn(true, animated:true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: function for cancel button
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: function to check icloud container availability and take action
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
       
        if !cloudstatus.isEmpty {
            createAlert(title: "Attention", text: cloudstatus)
        }else {
            saveCoursetoPrivateDB()
        }
        
    }
    
    //MARK: function for save  course data to coredata
    private func saveCoursetoPrivateDB(){

        //prevent multiple save
        
        cancelButton.isEnabled = false
        saveButton.isEnabled = false

        let course=CKRecord(recordType: "Course")
        course.setObject(self.courseIdTextField.text as CKRecordValue?, forKey: "ID")
        course.setObject(self.courseNameTextField.text as CKRecordValue?, forKey: "Name")
        
        if !(courseIdTextField.text?.isEmpty)! && !(courseNameTextField.text?.isEmpty)! {
            privateDB.save(course) { (saveRecord, error) in
                if error != nil{
                    
                    print (error?.localizedDescription ?? "")
                    //put to main thread
                    OperationQueue.main.addOperation {
                        self.createAlert(title: "Attention", text: self.message)
                    }
                }
                else
                {
                    OperationQueue.main.addOperation {
                     //   self.present(self.alert,animated: true, completion: nil)
                        self.createAlert(title: "Congratulation", text: "You have successfully created a new course!")

                        self.courseIdTextField.text = nil
                        self.courseNameTextField.text = nil
                        print("Data Save to CloudKit successfully!")
                    }
                }
            }
        } else{
            //display alert is field is empty
            self.createAlert(title: "Attention", text: "Empty content is not saved!")
        }
    }
    
    //MARK: function to get the course from cloud
    @IBAction func scanCourse(_ sender: Any) {
        
        if !cloudstatus.isEmpty {
            createAlert(title: "Attention", text: cloudstatus)
        }else {
            //Perform search function from cloudkit
            predicatequery()
        }
    }
    
    //MARK: function to perform query by predicate
    private func predicatequery(){
        
        //Define predicate for search, put studentid and beanname
        let enrollPredicate = NSPredicate(format: "studentid = %@ AND beanid =%@", studentIdTextField.text!, yourBean?.name ?? "")
        
        //Define query
        let enrollquery = CKQuery(recordType: "CourseStudent", predicate: enrollPredicate)
        
        //Perform query to public database
        publicDB.perform(enrollquery, inZoneWith: nil) { (results, error) in
            if (error != nil) {
                //display error
                DispatchQueue.main.async(){
                    self.createAlert(title:"Cloud Access Error", text: error!.localizedDescription)
                }
            }else {
                //display value to input field
                if results!.count > 0 {
                    let record = results! [0]
                    self.currentRecord = record
                    DispatchQueue.main.async(){
                        self.courseIdTextField.text = record.object(forKey: "courseid") as? String
                        self.courseNameTextField.text = record.object(forKey: "coursename") as? String
                        
                    }
                }else {
                    //empty current field when no record found
                    DispatchQueue.main.async(){
                        self.createAlert(title: "No Match Found", text: "This Studentid is not enrolled")
                        self.courseIdTextField.text = nil
                        self.courseNameTextField.text = nil
                        
                    }
                }
            }
        }
    }
    
    
    //Bean SDK: check to see if Bluetooth is on
    func beanManagerDidUpdateState(_ beanManager: PTDBeanManager!) {
        
        //start scan for bean
        startScanning()
        
        if beanManager!.state == BeanManagerState.poweredOn {
            
            //handle error
            if  let  e = scanError {
                
                print(e)
            }
        } else{
            //crete alert when bluetooth not poweron
            if (userDefault.bool(forKey: switchKeyConstant)) {
                createAlert(title: "Attention", text: "Auto-mapping, please turn on bluetooth")
            }
        }
    }
    
    
    //MARK: function to create alert view
    func createAlert(title: String, text: String) {
        
        //define alert, set title and message
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        
        //add action for tapping on "delete all" button
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
        
            self.saveButton.isEnabled = true
            self.cancelButton.isEnabled = true

        
        }))
        
        //present the alert
        self.present(alert, animated:true, completion: nil)
    }
    
    //MARK: Scan for Beans
    func startScanning() {
        var error: NSError?
        beanManager!.startScanning(forBeans_error: &error)
    }
    
    //MARK: Connect to a specific Bean
    func beanManager(_ beanManager: PTDBeanManager!, didDiscover bean: PTDBean!, error: Error!) {
        if let e = error{
            print(e)
        }
        if bean.name == "CowBean" {
            yourBean = bean
            //Unhide Student Info when bean found
            if (yourBean?.name.isEmpty)! {
                
                studentInfo.isHidden = true
            } else {
                studentInfo.isHidden = false
                print(yourBean?.name ?? "")
            }
        }
    }
    
    //MARK: function for double tap gesture to save record to public database when iCloud container is available
    @IBAction  func doubleTapped(_ sender:UITapGestureRecognizer){
        
        if !cloudstatus.isEmpty {
            createAlert(title: "Attention", text: cloudstatus)
        } else {
           saveCoursetoPublicDB()
        }
    }
    
    //MARK: func to save coursestudent records to publidDB
    private func saveCoursetoPublicDB(){
        
        //For demonstration purpose, set beanid with the name of the testing Bean used
        let beanid = "CowBean"
        
        //Define public data
        let publicData = CKRecord(recordType: "CourseStudent")
        publicData.setObject(self.courseIdTextField.text as CKRecordValue?, forKey: "courseid")
        publicData.setObject(self.courseNameTextField.text as CKRecordValue?, forKey: "coursename")
        publicData.setObject(self.studentIdTextField.text as CKRecordValue?, forKey: "studentid")
        publicData.setObject(beanid as CKRecordValue, forKey: "beanid")
        
        //set to check the fields is not empty when saving data
        if !(courseIdTextField.text?.isEmpty)! && !(courseNameTextField.text?.isEmpty)! && !(studentIdTextField.text?.isEmpty)! && !beanid.isEmpty {
            
            publicDB.save(publicData) { (saveRecord, error) in
                if error != nil{
                    OperationQueue.main.addOperation {
                        self.createAlert(title: "Attention", text: (error?.localizedDescription)!)
                    }
                    print("error saving ---" + (error?.localizedDescription)!)
                }else{
                    OperationQueue.main.addOperation {
                        self.createAlert(title: "Attention", text: "Records successfully added!")
                    }
                }
            }
            self.studentIdTextField.text = nil
            
        } else{
            self.createAlert(title: "Attention", text: "Empty content is not saved.")
        }
    }
}
