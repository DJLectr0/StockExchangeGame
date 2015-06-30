//
//  ViewController.swift
//  stockexchange
//
//  Created by Leonardo Galli on 14.06.15.
//  Copyright (c) 2015 SleepyImpStudio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var game: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if(identifier == "join"){
            var game = self.game.text;
            
            let url = NSURL(string: "http://leonardogalli.ch/stockexchange/getPrice.php?game="+game)
            
            var resp = ""
            
            send("http://leonardogalli.ch/stockexchange/getPrice.php?game="+game, f: {(result: String)-> () in
                println(result)
                resp = result
            })
            
            if(resp == ""){
                var alert = UIAlertController(title: "Game not found", message: "The game you entered could not be found", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return false;
            }
            
        }
        
        return true;
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var vc: UIViewController = segue.destinationViewController as! UIViewController
        if(segue.identifier == "join"){
            var jc : JoinedGameController = vc as! JoinedGameController
            jc.setGame(self.game.text)
        }else if(segue.identifier == "create"){
            var cc : CreateGameController = vc as! CreateGameController
            cc.createGame(self.game.text)
        }
        
        
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

