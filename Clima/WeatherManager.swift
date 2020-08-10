//
//  What Is the Difference Between Core Data and SQLite.swift
//  Clima
//
//  Created by Hady on 6/9/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager : WeatherManager ,weather: WeatherModel)
    func didFailWithError(error : Error)
}


struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=c6d2989fba17d29622a94954cca84244&units=metric"
    var delegate : WeatherManagerDelegate?
    
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
    
        performRequest(with: urlString)
    }
    
    func fetchWeather (longtude : CLLocationDegrees , latitude : CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longtude)"
        performRequest(with: urlString)
    }
    
    
    func performRequest (with urlString : String){
        //Create URL
        if let url = URL(string: urlString){
            
            //Create URL Session
            let session  = URLSession(configuration: .default)
            
            //Give Session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    // let dataString = String(data: safeData, encoding: .utf8)
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                        
                    }
                    //else{}
                }
            }
            //Start the task
            task.resume()
        }
    }
    func parseJSON (_ weatherData : Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let tempreture = decodedData.main.temp
            let wthr = WeatherModel(conditionId: id, cityName: name, temp: tempreture)
            print("This is the current city name\(wthr.cityName)")
            
            return wthr
        } catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
