//
//  SecondViewController.swift
//  wv4test
//
//  Created by KRogLA on 31/05/2019.
//  Copyright © 2019 KRogLA. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    var logController: LogController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        title = "Logs"
        textView.isEditable = false
        logController = LogController.instance
//        logController.addLog("loaded")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = logController.logs
    }
}

