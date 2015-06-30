//
//  ViewController.swift
//  stockexchange
//
//  Created by Leonardo Galli on 14.06.15.
//  Copyright (c) 2015 SleepyImpStudio. All rights reserved.
//

import UIKit
import QuartzCore

class JoinedGameController: UITableViewController, UITableViewDelegate, UITableViewDataSource  {

    internal var gameName: String = ""
    internal var prices = OrderedDictionary<String, OrderedDictionary<String, String>>()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setGame(game: String){
        self.gameName = game
        
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(self.gameName, forKey: "game")
        defaults.synchronize()
        
        var application = UIApplication.sharedApplication()
        
        if application.respondsToSelector("registerUserNotificationSettings:") {
            
            let types:UIUserNotificationType = (.Alert | .Badge | .Sound)
            let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
            
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            println("register token")
            
        } else {
            // Register for Push Notifications before iOS 8
            application.registerForRemoteNotificationTypes(.Alert | .Badge | .Sound)
        }
        
        //Get current price
        send("http://leonardogalli.ch/stockexchange/games/"+self.gameName+"/products.json", f: { (result) -> () in
            println(self.gameName)
            println(result)
            
            var json = NSJSONSerialization.JSONObjectWithData(result.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary
            
            for (product, price) in json!{
                var curLetter: String! = (product as! String)[0]
                curLetter = curLetter.lowercaseString
                if(self.prices[curLetter] == nil){
                    self.prices[curLetter] = OrderedDictionary<String, String>()
                }
                
                self.prices[curLetter]?[product as! String] = price as? String
            }
            self.prices.sortKeys{$0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending}
            for letter in self.prices.keys{
                var dict = self.prices[letter]! as OrderedDictionary
                dict.sortKeys{$0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending}
                self.prices[letter] = dict
            }
            
        })
        
        
        println(self.prices)
        
        //println("Current Stock Price: " + self.pric + "$")
        
    }
    
    func send(url: String, f: (String)-> ()) {
        var request = NSURLRequest(URL: NSURL(string: url)!)
        var response: NSURLResponse?
        var error: NSErrorPointer = nil
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: error)
        var reply = NSString(data: data!, encoding: NSUTF8StringEncoding)
        f(reply! as String)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.prices.keys.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //println(self.products[self.products.keys[section]])
        return self.prices[self.prices.keys[section]]!.keys.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("display") as! DisplayPriceTableViewCell
        
        var prods = self.prices[self.prices.keys[indexPath.section]]
        var productName = prods!.keys[indexPath.row] as String
        var price = prods![productName]
        cell.configure(productName, price: price!)
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.prices.keys[section].uppercaseString
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return self.prices.keys
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return index
    }
    
    func changedPrice(newPrices : Dictionary<String, String>){
        for (product, price) in newPrices{
            var letter : String = product[0].lowercaseString
            
            var prods = self.prices[letter]
            
            NSLog(product)
            var item = find(prods!.keys, product)!
            var section = find(self.prices.keys, letter)!
            var indexPath = NSIndexPath(forItem: find(prods!.keys, product)!, inSection: find(self.prices.keys, letter)!)
            
            var cell = self.tableView.cellForRowAtIndexPath(indexPath)
            
            
            if(cell != nil){
                var displayCell = cell as! DisplayPriceTableViewCell
                displayCell.setPriceNum(price)
            }
            prods![product] = price
            
            self.prices[letter] = prods
        }
        
        
    }
    
    
}
