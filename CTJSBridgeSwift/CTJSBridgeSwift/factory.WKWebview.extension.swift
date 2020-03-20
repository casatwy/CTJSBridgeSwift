//
//  factory.WKWebview.extension.swift
//  CTJSBridgeSwift
//
//  Created by casa on 2020/3/20.
//  Copyright © 2020 casa. All rights reserved.
//

import WebKit

public extension WKWebView {
    convenience init(configuration:WKWebViewConfiguration = WKWebViewConfiguration.init(), userAgentModification:((String)->String)? = nil) {
        guard let bridgePath = Bundle.main.path(forResource: "CTJSBridgeSwift", ofType: "js") else {
            self.init(frame: .zero, configuration: WKWebViewConfiguration.init())
            return
        }
        guard let bridgeScript = try? String.init(contentsOfFile: bridgePath) else {
            self.init(frame: .zero, configuration: WKWebViewConfiguration.init())
            return
        }
        
        let userScript = WKUserScript.init(source: bridgeScript, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(userScript)
        
        self.init()
    }
}

enum CTCallbackResult : String {
    case success
    case fail
    case progress
}

func ctCallback(result:CTCallbackResult, data:[AnyHashable:Any]?, message:WKScriptMessage, identifier:String) {
    var resultData:[AnyHashable:Any] = data ?? [:]
    resultData["result"] = result.rawValue
    guard let resultJSONData = try? JSONSerialization.data(withJSONObject: resultData, options: []) else { return }
    let encodedResultData = resultJSONData.base64EncodedString(options: .endLineWithLineFeed)
    
    if Thread.isMainThread {
        message.webView?.evaluateJavaScript("window.CTJSBridgeSwiftCallback('\(identifier)','\(result.rawValue)','\(encodedResultData)')", completionHandler: nil)
    } else {
        DispatchQueue.main.sync {
            message.webView?.evaluateJavaScript("window.CTJSBridgeSwiftCallback('\(identifier)','\(result.rawValue)','\(encodedResultData)')", completionHandler: nil)
        }
    }
}
