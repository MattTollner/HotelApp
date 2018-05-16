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
    
   
    
    
    var roomsList = [Room]()
    var bookingList = [Booking]()
    let db = Firestore.firestore()
    var potentailBookings = [Booking]()
    
    var roomTypeArrIndex = 0
    var roomIDs = [String]()
    var potentialRooms = [Room]()
    var unavailableRooms = [String]()
    var unavailableRoomType = [String]()
    //var reservedRoom = [potentialRooms]
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var nightsTextField: UITextField!
    @IBOutlet weak var roomCountTextFiled: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var stepper: UIStepper!
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var checkButton: UIButton!
    var roomIndex = 0
    var potentailRoomIndex = 0
    @IBOutlet weak var tableView: UITableView!
    
    var roomTypeArr = [String]()
    var tempRoomTypeArr = ["","","","",""]
    var nights = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15"]
    var rooms = ["1","2","3","4"]
    var nightsSelected = true
    var dataSource = [String]()
    //  var cellsArr = [BookingRoomTableViewCell]()
   // var roomTypeArr = [String]()
    func testTapped(_ sender: Any) {
        tableView.reloadData()
    }
    
    
    let picker = UIDatePicker()
     let thePicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        //pickerView.delegate = self
        thePicker.delegate = self
        
        
        //tableView.isUserInteractionEnabled = false
        setUpDatePicker()
        // getBookings(roomID: "FFPxRPUt0mBJrsBVJ8Sd")
        // getRooms(roomType:"")
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(updateTheTable(_:)), for: .valueChanged)
        
        
       
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([doneButton], animated: true)
        nightsTextField.inputAccessoryView = toolBar
        roomCountTextFiled.inputAccessoryView = toolBar
        
        nightsTextField.inputView = thePicker
        roomCountTextFiled.inputView = thePicker
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("View appear")
        roomIDs = []
    }
    
    @objc func doneClicked(){
        view.endEditing(true)
    }
    
    
    
    
    @objc private func updateTheTable(_ sender: Any) {
        tableView.reloadData()
    }
    @IBAction func testTable(_ sender: Any) {
        tableView.reloadData()
    }
    
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
            print("nights did select row " + nights[row])
            nightsTextField.text = nights[row]
        }else{
            print("room did select row " + rooms[row])
            roomCountTextFiled.text = rooms[row]
        }
    }
    
    func checkValues() -> Bool{
        
        var valuesValid = true
        nightsTextField.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        dateTextField.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        roomCountTextFiled.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        roomCountTextFiled.placeholder = ""
        nightsTextField.placeholder = ""
        
      
        
        //Checking Room Count Text Filed
        if let roomsCount = roomCountTextFiled.text{
            if(!roomsCount.isNumeric){
                //FAIL room count not a number
                print("Room count not a number")
                roomCountTextFiled.backgroundColor = #colorLiteral(red: 1, green: 0.2551919259, blue: 0.1199331933, alpha: 1)
                valuesValid = false
            }else {
                let testInt : Int
                testInt = Int(roomsCount)!
                if(testInt > 15){
                    print("Cant book more than 15 rooms at once")
                    roomCountTextFiled.backgroundColor = #colorLiteral(red: 1, green: 0.2551919259, blue: 0.1199331933, alpha: 1)
                    roomCountTextFiled.placeholder = "Max 15"
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
                    nightsTextField.placeholder = "Max 28"
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
    
    @IBAction func testButton(_ sender: Any) {
        
        if(checkValues()){
            
            
            if(nightsTextField.text != "")
            {
                activityIndicator.startAnimating()
                enableControl(binary: 0)
                roomTypeArrIndex = 0
                potentialRooms = []
                potentailBookings = []
                unavailableRooms = []
                unavailableRoomType = []
                roomTypeArr = []
                //getRooms(roomType: roomTypeArr2[roomIndex])
                tableView.reloadData()
                for i in tempRoomTypeArr {
                    if i == "" {
                        
                    } else {
                        roomTypeArr.append(i)
                    }
                }
                
                for i in roomTypeArr {
                    print ("Room TYpe :  + " + i)
                }
                testQ(roomType: roomTypeArr[roomTypeArrIndex])
                
                
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
        //roomCountTextFiled.text = "1"
    
    }
    @IBAction func touchUpRooms(_ sender: Any) {
        print("touch up room")
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookingCell", for: indexPath) as! BookingRoomTableViewCell
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        cell.roomIteration .text = "Room " + String(indexPath.row)
        
        
        //cell.roomType.text = roomsList[indexPath.row].RoomType
        cell.priceTextField.text = "N/A"
        
     
        if(indexPath.row == 0){
            tempRoomTypeArr =  ["","","",""]
        }
        
        self.tempRoomTypeArr[indexPath.row] = cell.roomTypeLabel.text!
       // self.roomTypeArr.insert(cell.roomTypeLabel.text!, at: indexPath.row)
        

     //   roomTypeArr.append(cell.roomTypeLabel.text!)
       // roomTypeArr[indexPath.row] = cell.roomTypeLabel.text!
        for i in tempRoomTypeArr{
            print("TEMP Room Type : " + i)
        }
        
        if (!potentialRooms.isEmpty){
            var makeRed = -1
            
            print("CHECKING CELL DATA " + cell.roomTypeLabel.text!)
            
            if unavailableRoomType.contains(cell.roomTypeLabel.text!) {
                makeRed = 1
                
                for i in 0...unavailableRoomType.endIndex{
                    if(unavailableRoomType[i] == cell.roomTypeLabel.text!){
                        unavailableRoomType.remove(at: i)
                        break
                    }
                }
            } else {
                makeRed = 0
            }
   
            
            if makeRed == 1 {
                cell.backgroundColor = UIColor.red
                print("Unable to book " + String(cell.roomIteration.text!))
            } else if makeRed == 0 {
                cell.backgroundColor = UIColor.green
            } else {
                cell.backgroundColor  = UIColor.gray
            }
        } else{
            print("Potentail Rooms Empty")
        }
        
        return cell
    }
    
    func alertShow(type : Int){
        
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
    
    func testQ(roomType : String)
    {
        promiseGetBookings()
        .then() {
                bookings in
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
                    if i.RoomType == self.roomTypeArr[self.roomTypeArrIndex]{
                        if self.roomIDs.contains(i.RoomID){
                            print("Room " + i.RoomID + " in roomIDS list")
                            continue
                        }
                        canBookRoomType = true
                        print("I belive you can book this room " + i.RoomID + " Room Type :  " + i.RoomType)
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
    
    func endResultPromise() -> Promise<String>{
        return Promise { fulfil, reject in
            
            
            if(roomIDs.isEmpty){
                print("Unable to book requested room types for chosen date")
                fulfil("Unable to book requested room types for chosen date")
            }
            else if(!roomIDs.isEmpty && !unavailableRooms.isEmpty){
                print("Some room types were unavailable")
                fulfil("Some rooms types were unnavailalbe")
                 performSegue(withIdentifier: "toSummary", sender: self)
            }
            else if(!roomIDs.isEmpty && unavailableRooms.isEmpty){
                print("All rooms available to book")
                fulfil("All rooms available to book")
                performSegue(withIdentifier: "toSummary", sender: self)
            }
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
                self.testQ(roomType: self.roomTypeArr[self.roomTypeArrIndex])
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
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let sDate = dateTextField!.text
            let StartB = dateFormatter.date(from: sDate!)
            var dateComponent = DateComponents ()
            dateComponent.day = 3
            let EndB = Calendar.current.date(byAdding: dateComponent, to: StartB!)
            
            self.db.collection("Booking").whereField("CheckIn", isLessThanOrEqualTo: EndB!).getDocuments(completion: { (snapshot, error) in
                if let error = error {
                    self.fireError(titleText: "Error fetching rooms", lowerText: error.localizedDescription)
                    reject(error)
                }else
                {
                    for document in snapshot!.documents{
                        let booking = Booking(dictionary : document.data() as [String : AnyObject])
                        //print("Booking documetn for room " + booking.RoomID)
                
                        if booking.checkAvailability(sDate: sDate!){
                            for e in booking.RoomID {
                                self.potentailBookings.append(booking)
                                print("Booking available for room " + e)
                            }
                            
                            break
                        } else {
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
