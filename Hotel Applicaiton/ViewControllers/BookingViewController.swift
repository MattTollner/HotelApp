//

import UIKit
import Firebase
import PromiseKit

extension String {
    var isAlphaCharacter : Bool {
        return !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^0-9]", options: .regularExpression) == nil
    }
    
    var isCharacter : Bool {
        return !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }
    
    var isNumeric : Bool {
        return !isEmpty && range(of: "[^0-9]", options: .regularExpression) == nil
    }
}


class BookingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
   
    
    
   

    //UI Elemements
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var nightsTextField: UITextField!
    @IBOutlet weak var roomCountTextFiled: UITextField!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let refreshControl = UIRefreshControl()
    let picker = UIDatePicker()
    let thePicker = UIPickerView()
    
    //Data arrays
    var bookingList = [Booking]()
    var potentailBookings = [Booking]()
    var roomIDs = [String]()
    
    var unavailableRooms = [String]()
    var unavailableRoomType = [String]()
    
    var roomIndex = 0
    var roomsList = [Room]()
    var potentailRoomIndex = 0
    var potentialRooms = [Room]()
    var roomTypeArrIndex = 0
    var roomTypeArr = [String]()
    
    //Populated by room types requested by user
    var tempRoomTypeArr = ["","","","",""]
    var nights = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15"]
    var rooms = ["1","2","3","4"]
    var nightsSelected = true
    var dataSource = [String]()
    
    var db = Firestore.firestore()
    
    func testTapped(_ sender: Any) {
        tableView.reloadData()
    }
    
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Inital Setup
        tableView.delegate = self
        tableView.dataSource = self
        thePicker.delegate = self
        setUpDatePicker()
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(updateTheTable(_:)), for: .valueChanged)
        
        //Keyboard done button setup
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([doneButton], animated: true)
        
        nightsTextField.inputAccessoryView = toolBar
        roomCountTextFiled.inputAccessoryView = toolBar
        nightsTextField.inputView = thePicker
        roomCountTextFiled.inputView = thePicker
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("View appear")
        roomIDs = []
    }
    
    @objc func doneClicked(){
        //Close keyboard
        view.endEditing(true)
    }
    
    @objc private func updateTheTable(_ sender: Any) {
        tableView.reloadData()
    }
    @IBAction func testTable(_ sender: Any) {
        tableView.reloadData()
    }
    
    //Picker view setup
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(nightsSelected){
            return nights.count
        } else {
            return rooms.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(nightsSelected){
            return nights[row]
        } else {
            return rooms[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(nightsSelected){
            nightsTextField.text = nights[row]
        }else{
            roomCountTextFiled.text = rooms[row]
        }
    }
    
    func checkValues() -> Bool{
        
        var valuesValid = true
        nightsTextField.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        dateTextField.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        roomCountTextFiled.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        //Checking Room Count Text Filed
        if let roomsCount = roomCountTextFiled.text{
            if(!roomsCount.isNumeric){
                roomCountTextFiled.backgroundColor = #colorLiteral(red: 1, green: 0.2551919259, blue: 0.1199331933, alpha: 1)
                valuesValid = false
            }else {
                let testInt : Int
                testInt = Int(roomsCount)!
                if(testInt > 4){
                    roomCountTextFiled.backgroundColor = #colorLiteral(red: 1, green: 0.2551919259, blue: 0.1199331933, alpha: 1)
                    valuesValid = false
                }
            }
            
        } else {
            //FAIL room count empty
            print("Room count empty")
            roomCountTextFiled.backgroundColor  = #colorLiteral(red: 1, green: 0.2551919259, blue: 0.1199331933, alpha: 1)
            valuesValid = false
        }
        
        //Checking Nights Count Text Filed
        if let nightCount = nightsTextField.text{
            if(!nightCount.isAlphanumeric){
                //FAIL room count not a number
                print("Night count not a number")
                nightsTextField.backgroundColor = #colorLiteral(red: 1, green: 0.2551919259, blue: 0.1199331933, alpha: 1)
                valuesValid = false
            }else {
                let testInt : Int
                testInt = Int(nightCount)!
                if(testInt > 28){
                    print("Cant book more than 28 nights at once")
                    nightsTextField.backgroundColor = #colorLiteral(red: 1, green: 0.2551919259, blue: 0.1199331933, alpha: 1)
                    valuesValid = false
                }
            }
            
        } else {
            //FAIL room count empty
            print("Night count empty")
            nightsTextField.backgroundColor  = #colorLiteral(red: 1, green: 0.2551919259, blue: 0.1199331933, alpha: 1)
            valuesValid = false
        }
        
        
        //Checking Date Filed
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd-MM-yyyy"
        if let checkDate = dateTextField.text {
            
            if dateFormatterGet.date(from: checkDate) != nil {
                
            } else {
                // invalid format FAIL
                print("Date format incorrect")
                dateTextField.backgroundColor = #colorLiteral(red: 1, green: 0.2551919259, blue: 0.1199331933, alpha: 1)
                valuesValid = false
            }
            
        } else {
            //FAIL date empty
            print("Date field empty")
            dateTextField.backgroundColor = #colorLiteral(red: 1, green: 0.2551919259, blue: 0.1199331933, alpha: 1)
            valuesValid = false
        }
        
        if valuesValid {
            return true
        } else {
            return false
        }
    }
    func fireError(titleText : String, lowerText : String){
        let alert = UIAlertController(title: titleText, message: lowerText, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func checkButton(_ sender: Any) {
        
        if(checkValues()){
            
            
            if(nightsTextField.text != "")
            {
                //Reset arrays
                activityIndicator.startAnimating()
                enableControl(binary: 0)
                roomTypeArrIndex = 0
                potentialRooms = []
                potentailBookings = []
                unavailableRooms = []
                unavailableRoomType = []
                roomTypeArr = []
                tableView.reloadData()
                
                //Set room types ignorin blanks
                for i in tempRoomTypeArr {
                    if i == "" {
                        
                    } else {
                        roomTypeArr.append(i)
                    }
                }
                
                for i in roomTypeArr {
                    print ("Room TYpe :  + " + i)
                }
                
                if roomTypeArr.count != 0{
                    //Check availabity for first time in roomTypeArr
                    checkAvailability(roomType: roomTypeArr[roomTypeArrIndex])
                } else {
                    //No cells
                    print("roomTypeEmpty")
                    activityIndicator.stopAnimating()
                    tableView.reloadData()
                    checkButton.isEnabled = true
                    fireError(titleText: "Error table not loaded", lowerText: "Please try again")
                   
                }
            }
        }
    }
    @IBAction func payButton(_ sender: Any) {
        performSegue(withIdentifier: "toSummary", sender: self)
    }
    
    @IBAction func StepperChange(_ sender: Any) {
        print("Stepper Changed")
        roomTypeArr = []
       
        tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if  let destination = segue.destination as? BookingSummaryViewController {
                destination.checkIn = dateTextField.text!
                destination.nightsStaying = nightsTextField.text!
                print("ROOM IDS COUNT :: " + String(self.roomIDs.count))
                destination.roomIDs = self.roomIDs
            }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if let roomCount = roomCountTextFiled.text {
            if let roomCountInt : Int = Int(roomCount){
                count = roomCountInt
                print("Room count valid :: " + String(count))
            } else {
                count = 0
                print("Room Count Set 0 :  : " + String(count))
            }
        }
        return count
    }
    
    @IBAction func unwindToBooking(segue:UIStoryboardSegue) {
        print("UNWIND DETECTED")
    }
    
    
    
    @IBAction func editingNights(_ sender: Any) {
        nightsSelected = true
        thePicker.reloadAllComponents()
        print("Editing Nights")
        nightsTextField.text = "1"
    }
    
    @IBAction func touchUpInside(_ sender: Any) {
        print("touch up Nights")
    }
    
    @IBAction func editingRooms(_ sender: Any) {
        nightsSelected = false
        thePicker.reloadAllComponents()
        print("editing room")
        roomCountTextFiled.text = "1"
    }
    
    @IBAction func touchUpRooms(_ sender: Any) {
        print("touch up room")
    }
    
    
    @IBAction func editEndRooms(_ sender: Any) {
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookingCell", for: indexPath) as! BookingRoomTableViewCell
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        let id = indexPath.row + 1
        cell.roomIteration.text = "Room " + String(id)
        
        //If start reset room array
        if(indexPath.row == 0){
            tempRoomTypeArr =  ["","","",""]
        }
        
        self.tempRoomTypeArr[indexPath.row] = cell.roomTypeLabel.text!
     
        for i in tempRoomTypeArr{
            print("TEMP Room Type : " + i)
        }
        
        if (!potentialRooms.isEmpty){
            print("CHECKING CELL DATA " + cell.roomTypeLabel.text!)
            
            if unavailableRoomType.contains(cell.roomTypeLabel.text!) {
                for i in 0...unavailableRoomType.endIndex{
                    if(unavailableRoomType[i] == cell.roomTypeLabel.text!){
                        unavailableRoomType.remove(at: i)
                        break
                    }
                }
            }
           
        } else{
            print("Potentail Rooms Empty")
        }
        return cell
    }
    
    func alertShow(type : Int){
        //No rooms available
        if(type == 0){
            let conAlert = UIAlertController(title: "Room Availability", message: "Room types are not available for the time frame selected", preferredStyle: UIAlertControllerStyle.alert)
            
            conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                self.tableView.reloadData()
            }))
            self.present(conAlert, animated: true, completion: nil)
        } else {
            let conAlert = UIAlertController(title: "Room Availability", message: "Some room types were not available for the time frame selected", preferredStyle: UIAlertControllerStyle.alert)
            
            conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                self.performSegue(withIdentifier: "toSummary", sender: self)
            }))
            self.present(conAlert, animated: true, completion: nil)
        }
        
        
    }
    
    
    func setUpDatePicker(){
        
        //Toolbar set up
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        //Bar button
        let barButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(closeDatePicker))
        toolbar.setItems([barButton], animated: true)
        
        dateTextField.inputAccessoryView = toolbar
        
        // Connect date picker to text field
        dateTextField.inputView = picker
        
        let now = Date();
        picker.minimumDate = now
        
        //Format
        picker.datePickerMode = .date
        
    }
    
    
    
    @objc func closeDatePicker(){
        //Format text date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateTextField.text = dateFormatter.string(from: picker.date)
        self.view.endEditing(true)
    }
    
    func checkAvailability(roomType : String)
    {
        promiseGetBookings()
        .then() {
                bookings in
                //Get get all rooms of set type (currentTypeIndex)
                return self.promiseGetRooms(roomType: roomType)
        }
        .then { obj -> Void in
            var canBookRoomType = false
            for i in self.potentialRooms {
                if self.unavailableRooms.contains(i.RoomID){
                    if(roomType == i.RoomType){
                        print("Unable to book room as it has been booked by another " + i.RoomID)
                        canBookRoomType = false
                    }
                    continue
                } else {
                    //Does the potentail room match the room type looking for
                    if i.RoomType == self.roomTypeArr[self.roomTypeArrIndex]{
                        if self.roomIDs.contains(i.RoomID){
                            print("Room " + i.RoomID + " in roomIDS list")
                            continue
                        }
                        //Room bookable
                        canBookRoomType = true
                        print("Room available to book " + i.RoomID + " Room Type :  " + i.RoomType)
                        self.roomIDs.append(i.RoomID)
                        break
                    }
                }
            }
            
            if canBookRoomType == false {
                print("Unable to book a room for room type " + self.roomTypeArr[self.roomTypeArrIndex])
                self.unavailableRoomType.append(self.roomTypeArr[self.roomTypeArrIndex])
            }
            
            
            
        }
    
        .then { obj -> Void in
            print("getting next room type")
            self.getNextRoomType()
        }
        .then { obj -> Void in
           // self.endResult()
            print("ENd")
        }
        .catch(){
            err in
            print("Caught error")
        }
    }
    
    func hideElements(){
        tableView.isHidden = true
    }
    @IBAction func roomFieldChange(_ sender: Any) {
        print("reloading data rooms cahnge")
        tableView.reloadData()
    }
    @IBAction func roomsFieldChange(_ sender: Any) {
        if roomCountTextFiled.text == "" || roomCountTextFiled.text == nil{
            roomCountTextFiled.text = "0"
            tempRoomTypeArr = ["","","",""]
        } else {
            print("Reloading Table")
            tempRoomTypeArr = ["","","",""]
            tableView.reloadData()
        }
    }
    
    func endResult(){
        if(roomIDs.isEmpty){
            print("Unable to book requested room types for chosen date")
            alertShow(type: 0)
        }
        else if(!roomIDs.isEmpty && !unavailableRoomType.isEmpty){
            print("Some room types were unavailable")
            alertShow(type: 1)
        }
        else if(!roomIDs.isEmpty && unavailableRoomType.isEmpty){
            print("All rooms available to book")
            performSegue(withIdentifier: "toSummary", sender: self)
        }
    }
    
    
    
    func getNextRoomType() -> Promise<String>{
        return Promise { fulfil, reject in
            print("Getting next room type")
            
            self.roomTypeArrIndex += 1
            if self.roomTypeArrIndex >= self.roomTypeArr.endIndex {
                print("All booking room types checked arrays ready for processing")
                self.activityIndicator.stopAnimating()
                enableControl(binary: 1)
                self.activityIndicator.isHidden = true
                self.endResult()
                
                fulfil("All room types checked end of check availability")
                
            } else {
                print("Moving on to next room type " + self.roomTypeArr[self.roomTypeArrIndex])
                fulfil("Success")
                self.checkAvailability(roomType: self.roomTypeArr[self.roomTypeArrIndex])
            }
            
        }
    }
    
    func enableControl(binary : Int){
        if(binary == 0) {
            checkButton.isEnabled = false
        } else if (binary == 1){
            checkButton.isEnabled = true
        } else {
            print("Value not set to 0 or 1")
        }
    }
   
    
    func promiseGetRooms(roomType : String) -> Promise<[Room]>{
        return Promise { fulfil,reject in
            print("Searching for rooms with type " + roomType)
            self.db.collection("Rooms").whereField("RoomType", isEqualTo: roomType) .getDocuments(completion: { (snapshot, error) in
                if let error = error {
                    self.fireError(titleText: "Error fetching rooms", lowerText: error.localizedDescription)
                    reject(error)
                }else
                {
                    for document in snapshot!.documents{
                        let room = Room(dictionary : document.data() as [String : AnyObject])
                        self.potentialRooms.append(room)
                        
                    }
                    fulfil(self.potentialRooms)
                }
            })
        }
    }
    
    func promiseGetBookings() -> Promise<[Booking]>{
        return Promise { fulfil, reject in
            
            //Calculate end date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let sDate = dateTextField!.text
            let StartB = dateFormatter.date(from: sDate!)
            var dateComponent = DateComponents ()
            dateComponent.day = Int(nightsTextField.text!)
            let EndB = Calendar.current.date(byAdding: dateComponent, to: StartB!)
            
            print("END B DATE :: " + dateFormatter.string(from: EndB!))
            
            //Skips bookings reserved after checkout of enqury
            self.db.collection("Booking").whereField("CheckIn", isLessThanOrEqualTo: EndB!).getDocuments(completion: { (snapshot, error) in
                if let error = error {
                    self.fireError(titleText: "Error fetching rooms", lowerText: error.localizedDescription)
                    reject(error)
                }else
                {
                    
                    print("Bookings Count ::  " + String(snapshot!.documents.count))
                    
                    //For each booking check availability
                    for document in snapshot!.documents{
                        let booking = Booking(dictionary : document.data() as [String : AnyObject])
                
                        //Checks if booking clashses
                        if booking.checkAvailability(sDate: sDate!, nights: self.nightsTextField.text!){
                            //Add booking room ids to array
                            for e in booking.RoomID {
                                self.potentailBookings.append(booking)
                                print("Booking available for room " + e)
                            }
                            //break
                        } else {
                            //Add booking room ids to unavailable array
                            for ez in booking.RoomID {
                                self.unavailableRooms.append(ez)
                                print("Booking not availalbe for room " + ez)
                            }
                            continue
                        }
                    }                
                    fulfil(self.potentailBookings)
                }
            })
        }
    }
}
