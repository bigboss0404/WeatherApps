//
//  ViewController.swift
//  WeatherApp
//
//  Created by Dexter Yap on 26/03/2022.
//

// Weather Apps: Search for weather on city name and to retreive data for today as well as tomorrow. Display the date, city info (name and country), weather icon, current, min and max temperatures.

// 1) Make the API code based on URL store any incoming data || done***
    // format it correctly
    // send out request for the data
    // retrieve incoming data and store it, or print error message

// 2) Parse the retreive data and store the correct values
    // Seperate and store the data into seperate structs (take the most time)

// 3) Manipulate data into correct formats. (kelvin -> celcius)
    // Get current date and tomorrow and display this
    // convert and calculate the data we want
    // store the values in objects labels (need a seperate class for it)

// 4) Displaying data in the correct label (icon will required another API call)
    // Retrieving the values and displaying them in the correct labels
    // Retrieving Icon images and displa it in the imageView (<- inside your canva)

import UIKit

class ViewController: UIViewController {
    
    // Weather Page controller
    @IBOutlet weak var cityInfoLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var minAndMaxLabel: UILabel!
    
    var weatherDataHandler: WeatherDataHandler!
    var currentDay: Day = .today
    
    // memo
    @IBOutlet var taskTextField: UITextField!
    @IBOutlet var taskLabel: UILabel!
    
    var tasking = Tasking(task: "Bring Umbrella")
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dateLabel.text = "\(DateHandler.todaysDate)"
        
        getTaskFromLocal()
        updateUI()
        getTaskFromLocal()
        
        

    }
    
    @IBAction func updateButtonTap(_ sender: Any) {
        if
            let task = taskTextField.text,
            task != ""
        {
            // encode, save data in local perform here
            self.tasking = Tasking(task: task)
            
            let encoder = PropertyListEncoder()
            
            if let encodedTask = try? encoder.encode(self.tasking){
                UserDefaults.standard.set(encodedTask, forKey: "tasking")
            }
            
            
        }else{
            self.tasking = Tasking(task: "Remember...")
        }
        updateUI()
    }
    
    func getTaskFromLocal(){
        let decoder = PropertyListDecoder()
        
        if let storedObject = UserDefaults.standard.object(forKey:"tasking") as? Data,
           let decodedTask = try? decoder.decode(Tasking.self, from: storedObject)
        {
            self.tasking = decodedTask
        }
    }
    
    func updateUI(){
        taskLabel.text = "\(tasking.task)"
    }
    
    func updateTextFields(){
        taskTextField.text = tasking.task
    }
    
    //Weather View
    //Users Text Field
    @IBAction func endEditingTextField(_ sender: UITextField) {
        let baseURLString = "http://api.openweathermap.org/data/2.5/forecast?q="
        let APIKeyString = "&appid=1b0d77ce255219473b9194e69b8a25fd"
        guard let cityString = sender.text else { return }
        if let finalURL = URL(string: baseURLString+cityString+APIKeyString){ // new URL created here
            requestWeatherData(url: finalURL)// call out the request here
        }else{
            print("Malformed URL")
        }
    }
    
    // Weather request (background running task)
    func requestWeatherData(url:URL){
        let task = URLSession.shared.dataTask(with: url){ //creating request by the URL
            (data,resposne,error) in
            if let urlResposne = resposne{
                print(urlResposne)
            }
            if let errorResponse = error{
                print(errorResponse)
            }else if let dataResponse = data{ // always practice to put all the handling and displaying in the dataResponse
                // displayData() can be here
                self.weatherDataHandler = WeatherDataHandler(_data:dataResponse)
                self.weatherDataHandler.decodeData()
                
                let delay = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: delay, execute: {self.displayWeatherData()})
                
                
            }
        }
        task.resume()
        // diaplayData() cant be called here because we need to make sure every data handle properly
    }
    
    func displayWeatherData(){
        guard let weatherDataHandle = weatherDataHandler else { return }
        if let city = weatherDataHandle.cityString{
            self.cityInfoLabel.text = city
        }
        
        var day: WeatherByDay?
        switch self.currentDay {
        case .today:
            day = weatherDataHandle.todaysData
        case .tomorrow:
            day = weatherDataHandle.tomorrowsData
        }
        if let currentDay = day{
            minAndMaxLabel.text = "Min: \(currentDay.averageMinTemp)℃, Max: \(currentDay.averageMaxTemp)℃"
            getWeatherIcon(iconString: currentDay.iconString)
        }else{
            temperatureLabel.text = "no Data to Display"
            minAndMaxLabel.text = "No data to display"
        }
    }
    
    func getWeatherIcon(iconString: String){
        let baseURLString = "http://openweathermap.org/img/wn/"
        let endString = ".png"
        guard let iconURL = URL(string: baseURLString + iconString + endString) else { return }
        let task = URLSession.shared.dataTask(with: iconURL){ //creating request by the URL
            (data,resposne,error) in
            if let urlResposne = resposne{
                print(urlResposne)
            }
            if let errorResponse = error{
                print(errorResponse)
            }else if let dataResponse = data{
                let delay = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: delay, execute: {
                    self.displayIconImage(data: dataResponse)
                })
            }
        }
        task.resume()
    }
    
    func displayIconImage(data: Data){
        if let image = UIImage(data: data){
            self.imageView.image = image
        }else{
            print("could not convert image...")
        }
    }
    
    @IBAction func todayButton(_ sender: UIBarButtonItem) {
        currentDay = .today
        displayWeatherData()
        dateLabel.text = "\(DateHandler.todaysDate)"
    }
    @IBAction func tomorrowButton(_ sender: UIBarButtonItem) {
        currentDay = .tomorrow
        displayWeatherData()
        dateLabel.text = "\(DateHandler.tomorrowsDate)"
    }
    

}

