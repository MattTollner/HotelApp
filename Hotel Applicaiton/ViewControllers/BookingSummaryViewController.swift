import UIKit
import Firebase

class BookingSummaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    
    @IBOutlet weak var checkInLabel: UILabel!
    @IBOutlet weak var checkOutLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var extraPriceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var paymentSegment: UISegmentedControl!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var breakfastSegment: UISegmentedControl!
    var roomIDs = [String]()
    var breakfastRoomIDs  = ["","","","","","","","","","","","","","",""]
    var breakfastArray = ["n","n","n","n","n","n","n","n","n","n","n","n","n","n","n"]
    var roomsToBook = [Room]()
    var totalPrice : Double = 0
    var paymentPrice : Double = 0
    var checkIn : String = ""
    var roomCount : String = ""    
    var nightsStaying : String = ""
    var checkOut : String = ""
    var breakfastTotalAmount = 0.0
    
    @IBOutlet weak var percentageAmountLabel: UILabel!
    
    var roomPerNightCost = 0
    
    var sendCheckOut : Date = Date()
    var sendCheckIn : Date = Date()
    
     let db = Firestore.firestore()
    
    var paymentInPennys = 0
    var fullBookingCost = 0.0
    var depositAmount = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        percentageAmountLabel.isHidden = true
        getRooms()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func paySegmentChanged(_ sender: Any) {
        totalPrice(segmentIndex: paymentSegment.selectedSegmentIndex)
    }
    
    //Table view controls
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomsToBook.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookingCell", for: indexPath) as! BookingSummaryTableViewCell
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        cell.roomIteration.text = "Room " + String(indexPath.row)
        cell.roomTypeLabel.text = roomsToBook[indexPath.row].RoomType
        
        cell.roomPrice = Double(roomsToBook[indexPath.row].Price)!
        cell.priceLabel.text = String(cell.roomPrice)
        print("Room Standard Price at " + String(cell.roomPrice))
        
        if(indexPath.row == 0){
            print("Index path row at 0")
            roomPerNightCost = 0
            breakfastTotalAmount = 0.0
            totalPrice = 0.0
            breakfastRoomIDs = ["","","","","","","","","","","","","","",""]
        } else {
            print("Index path row not at 0")
        }
        if(cell.breakfastSegment.selectedSegmentIndex == 0){
            print("Selected Index at 0, adding room to breakfastRoomIDs") //Breakfast
            breakfastRoomIDs[indexPath.row] = (roomsToBook[indexPath.row].RoomID)
            print("Breakfasst total amount = " + String(breakfastTotalAmount) + " adding additional breakfast cost : " + String(cell.breakfastAmount))
            breakfastTotalAmount += cell.breakfastAmount
            totalPrice += cell.breakfastAmount
            totalPrice += cell.roomPrice
            print("Important Figures : roomPrice : " + String(cell.roomPrice) + " breakfastAmount : " + String(cell.breakfastAmount))
            let finPrice = cell.roomPrice + cell.breakfastAmount
            print("Fin Price Now At : " + String(finPrice))
            cell.priceLabel.text = String(finPrice)
        } else {
            //No breakfast
            print("Selected Index at 1 :: IndexPath.row : " + String(indexPath.row))
            
            breakfastRoomIDs[indexPath.row] = ""
            totalPrice += cell.roomPrice
            print("Total Price Seg : " + String(cell.roomPrice))
            cell.priceLabel.text = String(cell.roomPrice)
        }
        
        print("Total Price : " + String(totalPrice))
        print("Breakfast Amount : " + String(breakfastTotalAmount))
        priceLabel.text = String(totalPrice)
       // extraPriceLabel.text =  String(breakfastTotalAmount)
        totalPrice(segmentIndex: paymentSegment.selectedSegmentIndex)
        
       
        return cell
    }
    
    func getRooms(){
        roomsToBook = []
        db.collection("Rooms").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
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
            self.activityIndicator.stopAnimating()
            self.totalPrice(segmentIndex: self.paymentSegment.selectedSegmentIndex)
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
        totalPrice(segmentIndex: paymentSegment.selectedSegmentIndex)
        
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
        print("Reloading table data")
        tableView.reloadData()
 
    }
    

}
