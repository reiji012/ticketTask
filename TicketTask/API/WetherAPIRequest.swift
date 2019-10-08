//
//  WetherData.swift
//  TicketTask
//
//  Created by reiji matsumura on 2019/08/09.
//  Copyright © 2019 松村礼二. All rights reserved.
//

import Foundation
import SwiftyJSON

class WetherAPIRequest: NSObject {
    let baseUrl = "http://api.openweathermap.org/data/2.5/forecast"
    let apiKey = "8830d98e53e851b79f3ff73d30d609e4"
    var cellItems = NSMutableArray()
    
    func fetchWetherData(callback: @escaping (JSON?, Error?) -> Void){
        // openweathermapApiを用いて各情報を取得
        let url = NSURL(string: "\(baseUrl)?q=Tokyo,jp&units=metric&lang=ja&APPID=\(apiKey)")!
        let task = URLSession.shared.dataTask(with: url as URL, completionHandler: {data, response, error in
            do {
                let json = try! JSON(data: data!)
                print(json)
                callback(json, nil)
            }
        })
        task.resume()
    }
    
    func fetchWeatherIcon(iconId: String) -> UIImage {
        let baseUrl = "http://openweathermap.org/img/wn/\(iconId)@2x.png"
        // URLオブジェクトを作る
        let imgUrl = NSURL(string: baseUrl);
        
        // ファイルデータを作る
        let file = NSData(contentsOf: imgUrl! as URL);
        
        // イメージデータを作る
        let img = UIImage(data:file! as Data)
        return img!
    }
    
}
