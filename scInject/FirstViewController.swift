//
//  FirstViewController.swift
//  wv4test
//
//  Created by KRogLA on 31/05/2019.
//  Copyright © 2019 KRogLA. All rights reserved.
//

import UIKit
import WebKit


class FirstViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler, UITextViewDelegate {
    
    var webView: WKWebView!
    var logController: LogController!

    let testIdent: [String : Any] = [
        "hash": "cf057bbfb72640471fd910bcb67639c22df9f92470936cddc1ade0e2f2e7dc4f",
        "kyc": false,
        "name": "TestIdentity",
        "publicKey": "EOS572tM3oawChDic5odMo58SDdrwrmwFEkfEncMFtTuFQB2m8ezV",
        "accounts": [
            [
                "authority": "active",
                "blockchain": "eos",
                "name": "alice",
                "publicKey": "EOS572tM3oawChDic5odMo58SDdrwrmwFEkfEncMFtTuFQB2m8ezV",
                "chainId": "cf057bbfb72640471fd910bcb67639c22df9f92470936cddc1ade0e2f2e7dc4f",
            ],
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let url = URL(string: "https://betx.fun")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        logController = LogController.instance
    }
    
    override func loadView() {
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "scatterHandler")

//        let scriptPath1 = Bundle.main.path(forResource: "content", ofType: "js")
//        do {
//            let scriptSource1 = try String(contentsOfFile:scriptPath1!, encoding: String.Encoding.utf8)
//            print(scriptSource1)
//        } catch {
//            print("nil")
//        }
        
        guard let scatterHandlerPath = Bundle.main.path(forResource: "handler", ofType: "js"),
            let scatterHandlerSource = try? String(contentsOfFile: scatterHandlerPath, encoding: String.Encoding.utf8) else { return }
        guard let scatterInjectorPath = Bundle.main.path(forResource: "injector", ofType: "js"),
            let scatterInjectorSource = try? String(contentsOfFile: scatterInjectorPath, encoding: String.Encoding.utf8) else { return }
        
//            print(scriptSource1)
        let script1 = WKUserScript(source: scatterHandlerSource, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        userContentController.addUserScript(script1)
//                    print(scriptSource2)
        let script2 = WKUserScript(source: scatterInjectorSource, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        userContentController.addUserScript(script2)
        
//        let scriptSource = "window.webkit.messageHandlers.scatterHandler.postMessage(`{\"type\":\"test\",\"resolver\":\"123123\"}`);"
        //"const scatterHandler = new ScatterHandler({});"
//        "window.webkit.messageHandlers.scatterHandler.postMessage(`{\"type\":\"getOrRequestIdentity\",\"payload\":{\"network\":{},\"fields\":{\"accounts\":[{\"blockchain\":\"eos\",\"protocol\":\"https\",\"host\":\"proxy.eosnode.tools\",\"port\":443,\"chainId\":\"aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906\"}]},\"domain\":\"betx.fun\"},\"resolver\":\"844228313308688439228608\",\"domain\":\"betx.fun\",\"from\":\"injected\"}`);"
        let testScript = "window.webkit.messageHandlers.scatterHandler.postMessage(`{\"type\":\"test\",\"resolver\":\"123\"}`);"

        // Instantiate a WKUserScript object and specify when you’d like to inject your script
        // and whether it’s for all frames or the main frame only.
        let onloadScript = WKUserScript(
            source: "document.dispatchEvent(new CustomEvent('scatterLoaded'));" + testScript,
            injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        userContentController.addUserScript(onloadScript)

        
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        view = webView
    }
    
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        title = webView.title
//    }
//    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "scatterHandler", let messageBody = message.body as? String {
            logController.addRequest(messageBody)
            
            let data = Data(messageBody.utf8)
        
            do {
                // make sure this JSON is in the format we expect
                if var msg = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let type = msg["type"] as? String {
                        print("req", msg)
                        let payload: String
                        //switch by message type
//                        export const GET_OR_REQUEST_IDENTITY = 'getOrRequestIdentity';
//                        export const IDENTITY_FROM_PERMISSIONS = 'identityFromPermissions';
//                        export const FORGET_IDENTITY = 'forgetIdentity';
//                        export const REQUEST_SIGNATURE = 'requestSignature';
//                        export const ABI_CACHE = 'abiCache';
//                        export const REQUEST_ARBITRARY_SIGNATURE = 'requestArbitrarySignature';
//                        export const REQUEST_ADD_NETWORK = 'requestAddNetwork';
//                        export const AUTHENTICATE = 'authenticate';
//                        const ErrorCodes = {
//                            NO_SIGNATURE:402,
//                            FORBIDDEN:403,
//                            TIMED_OUT:408,
//                            LOCKED:423,
//                            UPGRADE_REQUIRED:426,
//                            TOO_MANY_REQUESTS:429
//                        }
                        switch type {
                            case "getOrRequestIdentity":
                                //emulating approve
                                let jsonData = try! JSONSerialization.data(withJSONObject: testIdent)
                                payload = String(data: jsonData, encoding: String.Encoding.utf8)!
                            //        print(payload)
                            case "requestSignature":
                                //emulating error respond, payload parameter isError=true
                                //i.e. we rejecting request with error code (codes see above)
                                //setting "payload" to empty value  will also produce error
                                payload = "{\"isError\":true,\"type\":\"request_reject\",\"message\":\"User canceled request\",\"code\":402}"
                        default:
                            payload = ""
                        }
                        //actualy we just send back entire received message
                        //but we can reduce it a bit
                        msg["payload"] = ""
                        let respData = try! JSONSerialization.data(withJSONObject: msg)
                        let respMsg = String(data: respData, encoding: String.Encoding.utf8)!

                        logController.addResponse(respMsg)
                        print("res", respMsg)
                        webView.evaluateJavaScript("scatterHandler.msgResponder(\(respMsg),\(payload))") { (result, error) in
                            if error != nil {
                                print(result!)
                            }
                        }
                    }
                }
            } catch {
                print("failed to parse", messageBody)
                return
            }
   
        }
    }
    
}

