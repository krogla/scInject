//
//  LogController.swift
//  wv4test
//
//  Created by KRogLA on 31/05/2019.
//  Copyright © 2019 KRogLA. All rights reserved.
//
class LogController {
    static let instance = LogController()
    var logs = ""
    
    func addRequest(_ text: String) {
        logs += "\n\nREQUEST: "+text
    }
    func addResponse(_ text: String) {
        logs += "\n\nRESPONSE: "+text
    }

}
