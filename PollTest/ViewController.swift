//
//  ViewController.swift
//  PollTest
//
//  Created by Martin Kautz on 22.07.15.
//  Copyright (c) 2015 Raketenmann. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var fetchTask: NSURLSessionDataTask = NSURLSessionDataTask()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        fetchWrapper()
    }

    func fetchWrapper() {
        println("New request")
        fetchTask = fetch({
            (result, error) in
            if let ships = result as? [[String:AnyObject]] {
                println("Got \(ships.count) ships")
            }
            // wait a little and poll again
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.fetchWrapper()
            }
        })
        fetchTask.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func fetch(completionHandler: (AnyObject?, NSError?) -> Void ) -> NSURLSessionDataTask {
        let session = NSURLSession.sharedSession()
        let urlString = "http://www.teambender.de/test.php"
        let url = NSURL(string: urlString)
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT

        let fetchTask = session.dataTaskWithURL(url!) {
            (data, response, error) -> Void in

            if let json: NSDictionary = NSJSONSerialization.JSONObjectWithData(
                data!,
                options: .MutableContainers,
                error: nil) as? NSDictionary {
                    if let ret = json["return"] as? String {
                        println(ret.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
                        println("*******************");
                        completionHandler(self.splitCSV(ret), nil)
                    }
            }
        }
        return fetchTask
    }

    func splitCSV(string: String) -> [[String : AnyObject]] {
        var newArray = [[String : AnyObject]]()
        var linesArray = split(string) {$0 == "\n"}
        for line in linesArray {
            var splittedLine = split(line, allowEmptySlices: true) {$0 == ";"}
            if splittedLine.count < 21 {
                println("No result!")
            }
            else {
                newArray.append(
                    [
                        "positionReceived"  : splittedLine[0],
                        "typeOfShipId"      : splittedLine[1],
                        "dimensionA"        : splittedLine[2],
                        "dimensionB"        : splittedLine[3],
                        "dimensionC"        : splittedLine[4],
                        "dimensionD"        : splittedLine[5],
                        "dimensionL"        : splittedLine[6],
                        "dimensionW"        : splittedLine[7],
                        "name"              : splittedLine[9],
                        "latitude"          : splittedLine[14],
                        "longitude"         : splittedLine[15],
                        "trueHeading"       : splittedLine[10],
                        "courseOverGround"  : splittedLine[11],
                        "speedOverGround"   : splittedLine[12],
                        "orient"            : splittedLine[13],
                        "typeOfShipIcon"    : splittedLine[18],
                        "objectId"          : splittedLine[19],
                        "age"               : splittedLine[20]
                    ]
                )
            }
        }
        return newArray
    }
}


