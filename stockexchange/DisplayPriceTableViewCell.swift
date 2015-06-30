//
//  ChangePriceTableViewCell.swift
//  stockexchange
//
//  Created by Leonardo Galli on 21.06.15.
//  Copyright (c) 2015 SleepyImpStudio. All rights reserved.
//

import UIKit

public class DisplayPriceTableViewCell: UITableViewCell {

    @IBOutlet weak var prodName: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var change: UILabel!
    
    public func configure(product: String, price: String) {
        self.prodName.text = product
        self.price.text = price + "$"
        self.change.text = ""
        
    }
    
    func setPriceNum(price: String){
        
        var change = (self.price.text as NSString?)!.doubleValue - (price as NSString).doubleValue
        if(change != 0){
            //Animate change
            self.price.text = price + "$"
            var sign = change > 0 ? "-" : "+"
            self.change.textColor = change > 0 ? UIColor(hue: 0, saturation: 0.98, brightness: 0.95, alpha: 1.0) : UIColor(hue: (109/360), saturation: 0.98, brightness: 0.8, alpha: 1.0)
            self.change.text = sign + String(format: "%.2f$", abs(change))
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.change.alpha = 1.0
                }) { (b) -> Void in
                    UIView.animateWithDuration(2.0, animations: { () -> Void in
                        //Nothing
                        self.change.alpha = 0.98
                        }, completion: { (b) -> Void in
                            UIView.animateWithDuration(0.5, animations: { () -> Void in
                                self.change.alpha = 0.0
                            })
                    })
            }
        }
        
    }
    
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.price.text = ""
        self.prodName.text = ""
        self.change.text = ""
        
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
