//
//  ChangePriceTableViewCell.swift
//  stockexchange
//
//  Created by Leonardo Galli on 21.06.15.
//  Copyright (c) 2015 SleepyImpStudio. All rights reserved.
//

import UIKit

public class ChangePriceTableViewCell: UITableViewCell {

    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var productName: UILabel!
    @IBAction func changePrice(sender: UITextField) {
        println(sender.text)
    }
    
    public override func layoutSubviews(){
        
        var toolbar = UIToolbar.new()
        toolbar.frame.size.height = 35
        
        var doneButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "hideKeyboard")
        
        var space:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        var items = [AnyObject]()
        items.append(space)
        items.append(doneButton)
        
        toolbar.items = items
        
        priceField.inputAccessoryView = toolbar
    }
    
    public func configure(product: String) {
        self.productName.text = product
        
        
    }
    
    func hideKeyboard() {
        println("Test")
        priceField.resignFirstResponder()
        
        var defaults = NSUserDefaults.standardUserDefaults()
        var game = defaults.valueForKey("game")
        var url = "http://leonardogalli.ch/stockexchange/changePrice.php?game=\(game as! String)&price=\(self.priceField.text)&product=" + self.productName.text!
        url = url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        println(url)
        send(url, f: { (result) -> () in
            println(result)
        })
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.priceField.text = ""
    }
    
    func send(url: String, f: (String)-> ()) {
        var request = NSURLRequest(URL: NSURL(string: url)!)
        var response: NSURLResponse?
        var error: NSErrorPointer = nil
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: error)
        var reply = NSString(data: data!, encoding: NSUTF8StringEncoding)
        f(reply! as String)
    }

    
    
}
