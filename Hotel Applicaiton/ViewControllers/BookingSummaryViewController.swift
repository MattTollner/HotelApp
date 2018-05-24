import UIKit
import Firebase

class BookingSummaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    //UI Elements
    @IBOutlet weak var checkInLabel: UILabel!
    @IBOutlet weak var checkOutLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var theButton: UIButton!
    @IBOutlet weak var extraPriceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var paymentSegment: UISegmentedControl!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var checkInSmallLabel: UILabel!
    @IBOutlet weak var checkOutSmallLabel: UILabel!
    @IBOutlet weak var breakfastSegment: UISegmentedControl!
    @IBOutlet weak var percentageAmountLabel: UILabel!
    
    var roomIDs = [String]()
    var breakfastRoomIDs  = ["","","",""]
    var breakfastArray = ["n","n","n","n"]
    var roomsToBook = [Room]()
    var totalPrice : Double = 0
    var paymentPrice : Double = 0
    var checkIn : String = ""
    var roomCount : String = ""    
    var nightsStaying : String = ""
    var checkOut : String = ""
    var breakfastTotalAmount = 0.0
    
    
    
    var roomPerNightCost = 0
    
    var theRoomArray = [Room]()
    var roomTuple : [(roomType: String, breakfast: Bool)] = [(roomType: "", breakfast: true),
                                                             (roomType: "", breakfast: true),
                                                             (roomType: "", breakfast: true),
                                                             (roomType: "", breakfast: true)]

    
    
    var sendCheckOut : Date = Date()
    var sendCheckIn : Date = Date()
    
     let db = Firestore.firestore()
    
    var paymentInPennys = 0
    var fullBookingCost = 0.0
    var depositAmount = 0.0
    
    var pricesPerNight = [0.0,0.0,0.0,0.0]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        percentageAmountLabel.isHidden = true
        getRooms()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func fireError(titleText : String, lowerText : String){
        let alert = UIAlertController(title: titleText, message: lowerText, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func paySegmentChanged(_ sender: Any) {
        //Colour price labels
        calculatePrice()
    }
    
    //Table view controls
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomsToBook.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookingCell", for: indexPath) as! BookingSummaryTableViewCell
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        //cell.roomIteration.text = "Room " + String(indexPath.row)
        
        print(":: CELL ROOMPRICE :: " + String(roomsToBook[indexPath.row].Price))
        print(":: CELL TYPE :: " + String(roomsToBook[indexPath.row].RoomType))
        cell.roomTypeLabel.text = roomsToBook[indexPath.row].RoomType
        
        if let roomCost = Double(roomsToBook[indexPath.row].Price){
            cell.roomPrice = roomCost
        } else {
            print("CONVERSTION ERROR")
        }
        
        
        cell.roomPrice = Double(roomsToBook[indexPath.row].Price)!
        cell.priceLabel.text = String(cell.roomPrice)
        print("Room Standard Price at " + String(cell.roomPrice))
         print("Room Full Price at " + String(cell.totalAmount))
        
        if(indexPath.row == 0){
            print("Index path row at 0")
            roomPerNightCost = 0
            breakfastTotalAmount = 0.0
            totalPrice = 0.0
            breakfastRoomIDs = ["","","",""]
        } else {
            print("Index path row not at 0")
        }
        if(cell.breakfastSegment.selectedSegmentIndex == 0){
            print("Selected Index at 0, adding room to breakfastRoomIDs") //Breakfast
            breakfastRoomIDs[indexPath.row] = (roomsToBook[indexPath.row].RoomID)
            print("setting prices per night CELL.totalamount = " + String(cell.totalAmount) + " roomAmount : " + String(cell.roomPrice))
            print("Cell.RoomType "  + String(cell.breakfastAmount))
            pricesPerNight[indexPath.row] = cell.totalAmount
            cell.priceLabel.text = "£"+String(cell.totalAmount)
           
        } else {
            //No breakfast
            print("Selected Index at 1 :: IndexPath.row : " + String(indexPath.row))
            print("setting prices per night CELL.totalamount = " + String(cell.totalAmount) + " roomAmount : " + String(cell.roomPrice))
            pricesPerNight[indexPath.row] = cell.roomPrice
            breakfastRoomIDs[indexPath.row] = ""
            cell.priceLabel.text = "£"+String(cell.roomPrice)
        }
        
        if(indexPath.row == roomsToBook.count - 1){
            print("Hit last row")
            print(pricesPerNight[0], pricesPerNight[1],pricesPerNight[2],pricesPerNight[3])
            calculatePrice()
        }
        
        print("Total Price : " + String(totalPrice))
        print("Breakfast Amount : " + String(breakfastTotalAmount))
        priceLabel.text = String(totalPrice)
       // extraPriceLabel.text =  String(breakfastTotalAmount)
        calculatePrice()

        
       
        return cell
    }

    func calculatePrice(){
        var roomCostBeforeNights = 0.0
        var totalCosts = 0.0
        var theDepositAmount = 0.0
        var paymentAmount = 0.0
        
        for i in pricesPerNight {
            print("Loop")
            roomCostBeforeNights += i
        }
        print("Oustide Loop")
        
        if let nights = Double(nightsStaying) {
            totalCosts = (roomCostBeforeNights * nights)
            print("Total Costs ::: " + String(totalCosts) )
            
            //Pay Full
            if paymentSegment.selectedSegmentIndex == 0 {
                percentageAmountLabel.isHidden = true
                theDepositAmount = 0.0
                paymentAmount = totalCosts
                priceLabel.text = "Total Amount : £" + String(paymentAmount)
                fullBookingCost = totalCosts
                print("Deposit Cost :: " + String(depositAmount))
                print("Total Costs ::: " + String(totalCosts) )
                print("Payment Amount ::: " + String(paymentAmount))
                
            } else {
                percentageAmountLabel.isHidden = false
                theDepositAmount = (totalCosts * 0.1)
                paymentAmount = theDepositAmount
                print("Deposit Cost :: " + String(depositAmount))
                print("Total Costs ::: " + String(totalCosts) )
                print("Payment Amount ::: " + String(paymentAmount))
            }
            depositAmount = theDepositAmount
            paymentInPennys = Int(paymentAmount * 100)
            priceLabel.text = "Total Amount : £" + String(totalCosts)
            percentageAmountLabel.text = "Deposit Amount : £" + String(depositAmount)
            fullBookingCost = totalCosts
          
        }
        
    }

    
    func getRooms(){
        
        theButton.isEnabled = false
        
        roomsToBook = []
        db.collection("Rooms").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                self.fireError(titleText: "Error fetching rooms", lowerText: error.localizedDescription)
            } else {
                for document in snapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let rooms = Room(dictionary: document.data() as [String : AnyObject])
                    if self.self.roomIDs.contains(rooms.RoomID){
                         self.roomsToBook.append(rooms)
                    }
                   
                }
            }
            self.tableView.reloadData()
            self.populateText()
            self.theButton.isEnabled = true
            self.activityIndicator.stopAnimating()
            self.calculatePrice()
           // self.totalPrice(segmentIndex: self.paymentSegment.selectedSegmentIndex)
        }
        
    }
    
    @IBAction func payButton(_ sender: Any) {
        performSegue(withIdentifier: "toPayment", sender: self)
    }
    
    @IBOutlet weak var breakfastSegmentChange: UISegmentedControl!
    
    @IBAction func breakfastSegChange(_ sender: Any) {
        
        populateText()
        tableView.reloadData()
    
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if  let destination = segue.destination as? PaymentViewController {
            let pennyAmount = paymentPrice * 100
            destination.depositAmount = depositAmount
            destination.paymentInPennys = paymentInPennys
            destination.fullBookingCost = fullBookingCost
            destination.breakfastRoomIDs = breakfastRoomIDs
            destination.amount = pennyAmount
            destination.roomIDs = roomIDs
            destination.checkInDate = sendCheckIn
            destination.checkOutDate = sendCheckOut
            
        }
    }
    
    func totalPrice(segmentIndex : Int){
        var totalAmount = 0.0
        var percentAmount = 0.0
        
        //Paynow selected
        if(segmentIndex == 0){
            totalAmount = totalPrice
            priceLabel.text = "Total Amount : £" + String(totalAmount)
            percentageAmountLabel.isHidden = true
            depositAmount = 0
            fullBookingCost = totalAmount
            paymentInPennys = Int(totalAmount * 100)
        } else {
            //Deposit selected
            percentageAmountLabel.isHidden = false
            totalAmount = totalPrice
            percentAmount = (totalAmount * 0.1)
            print("CALCULATE ::: Total Amount : " + String(totalAmount) + " Percent Amount : " + String(percentAmount))
            priceLabel.text = "Total Amount : £" + String(totalAmount)
            percentageAmountLabel.text = "Deposit Amount : £" + String(percentAmount)
            depositAmount = percentAmount
            fullBookingCost = totalAmount
            paymentInPennys = Int(totalAmount * 100)
        }
    }
    
    
    func populateText(){
        //Calculate cost
        //totalPrice(segmentIndex: paymentSegment.selectedSegmentIndex)
        calculatePrice()
        
        //Calculate Dates
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let sDate = checkIn
        let StartB = dateFormatter.date(from: sDate)
        var dateComponent = DateComponents ()
        dateComponent.day = Int(nightsStaying)
        let EndB = Calendar.current.date(byAdding: dateComponent, to: StartB!)
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        sendCheckIn = StartB!
        sendCheckOut = EndB!
        let longStart = dateFormatter.string(from: StartB!)
        let longEnd = dateFormatter.string(from: EndB!)
        checkInLabel.text = longStart
        checkOutLabel.text = longEnd
        if let info = HelperClass.hotelInfo {
            checkInSmallLabel.text = "Checking In : " + info.CheckIn
            checkOutSmallLabel.text = "Checking Out : " + info.CheckOut
        } else {
            checkInSmallLabel.text = "Checking In : 2pm"
            checkOutSmallLabel.text = "Checking Out : 12pm"
        }
        print("Reloading table data")
        tableView.reloadData()
 
    }
    

}
