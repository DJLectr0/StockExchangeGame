//
//  ViewController.swift
//  stockexchange
//
//  Created by Leonardo Galli on 14.06.15.
//  Copyright (c) 2015 SleepyImpStudio. All rights reserved.
//

import UIKit

class CreateGameController: UITableViewController, UITableViewDelegate, UITableViewDataSource {

    private var game : String = ""
    private var products = OrderedDictionary<String, [AnyObject]>()
    
    @IBOutlet weak var price: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.edgesForExtendedLayout=UIRect;
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func send(url: String, f: (String)-> ()) {
        var request = NSURLRequest(URL: NSURL(string: url)!)
        var response: NSURLResponse?
        var error: NSErrorPointer = nil
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: error)
        var reply = NSString(data: data!, encoding: NSUTF8StringEncoding)
        f(reply! as String)
    }
    
    
    @IBAction func changePrice(sender: UIButton) {
        send("http://leonardogalli.ch/stockexchange/changePrice.php?game="+game + "&price=" + self.price.text, f: { (result) -> () in
            println(result)
        })

    }
    
    func createGame(game: String){
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(game, forKey: "game")
        defaults.synchronize()
        
        send("http://leonardogalli.ch/stockexchange/createGame.php?game="+game, f: { (result) -> () in
            println(result)
            self.game = game
        })
        send("http://leonardogalli.ch/stockexchange/games/"+game+"/products.json", f: { (result) -> () in
            println(result)
            var json = NSJSONSerialization.JSONObjectWithData(result.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary
            
            var prods : [AnyObject] = []
            
            for (product,price) in json! {
                println(product)
                prods.append(product)
            }
            prods.sort{$0.localizedCaseInsensitiveCompare($1 as! String) == NSComparisonResult.OrderedAscending}
            println(prods)
            
            var lastLetter = "a"
            var prodsChar : [AnyObject] = []
            
            for product in prods {
                println(product)
                var curLetter: String! = (product as! String)[0]
                if(lastLetter.caseInsensitiveCompare(curLetter) == NSComparisonResult.OrderedAscending){
                    
                    if(prodsChar.count != 0){
                        prodsChar.sort{$0.localizedCaseInsensitiveCompare($1 as! String) == NSComparisonResult.OrderedAscending}
                        self.products[lastLetter] = prodsChar
                        prodsChar = []
                    }
                    lastLetter = curLetter.lowercaseString
                }
                
                prodsChar.append(product)
            }
            if(prodsChar.count != 0){
                prodsChar.sort{$0.localizedCaseInsensitiveCompare($1 as! String) == NSComparisonResult.OrderedAscending}
                self.products[lastLetter] = prodsChar
                prodsChar = []
            }
            
            println(self.products)
            
        })
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.products.keys.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //println(self.products[self.products.keys[section]])
        return self.products[self.products.keys[section]]!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("change") as! ChangePriceTableViewCell
        
        var prods = self.products[self.products.keys[indexPath.section]]
        var productName = prods?[indexPath.row] as! String
        cell.configure(productName)
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.products.keys[section].uppercaseString
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return self.products.keys
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return index
    }
}



extension String {
    
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
}


import Foundation

struct OrderedDictionary<Tk: Hashable, Tv> : Printable{
    var keys: Array<Tk> = []
    var values: Dictionary<Tk,Tv> = [:]
    
    var description: String {
        var result = "{\n"
        for i in 0...self.keys.count-1 {
            let key = self.keys[i]
            result += "[\(i)]: \(key) => \(self[key])\n"
        }
        result += "}"
        return result
    }
    
    init(){
        
    }
    
    subscript(key:Tk) -> Tv?{
        get{
            return self.values[key];
        }
        set(newValue){
            if (newValue == nil){
                self.values.removeValueForKey(key)
                self.keys.filter {$0 != key}
                return;
            }
            
            let oldValue = self.values.updateValue(newValue!, forKey: key);
            if oldValue == nil{
                self.keys.append(key);
            }
        }
    }
    
    func getPair(i: Int) -> (key: Tk, value: Tv)?{
        var key = self.keys[i];
        
        return (key, self.values[key]!);
    }
    
    mutating func sortKeys(f: (Tk, Tk) -> (Bool)){
        self.keys.sort(f)
    }
    
    
    
}