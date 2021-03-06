//
//  AlumniActivityView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/8/18.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import WebKit
import SCLAlertView

class AlumniActivityViewController:UIViewController,WKNavigationDelegate{
    
    @IBOutlet weak var stackView: UIStackView!
    
    var webview = WKWebView()
    var requestCookies = ""
    var in_url = ""
    override func viewDidLoad() {
        in_url = (tabBarController! as! AlumniRootViewController).in_url
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        super.viewDidLoad()
        let rightButton = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(previousPage))
        rightButton.icon(from: .FontAwesome, code: "reply", ofSize: 20)
        self.tabBarController?.navigationItem.rightBarButtonItem = rightButton
        setUpUI()
    }
    func setUpUI(){
        let theme = ThemeManager()
        self.navigationController?.navigationBar.barStyle = theme.typechoTheme.style
        self.navigationController?.navigationBar.barTintColor = theme.typechoTheme.titleBackgroundColor
        self.navigationController?.navigationBar.tintColor = theme.typechoTheme.titleButtonColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:theme.typechoTheme.titleButtonColor ?? UIColor.black]
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedStringKey.foregroundColor: theme.typechoTheme.titleButtonColor ?? UIColor.black
            ]
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        getToken()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func previousPage() {
        (stackView.viewWithTag(1) as! WKWebView).goBack()
    }
    
    
    func getToken(){
        let cookies:String = "token=" + UserDefaults.standard.string(forKey: "token")!
        let jsCookies = "document.cookie=\"" + cookies + "\"";
        self.requestCookies = cookies
        let cookieScript = WKUserScript(source: jsCookies, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
        let webviewConfig = WKWebViewConfiguration()
        let webviewController = WKUserContentController()
        webviewController.addUserScript(cookieScript)
        webviewConfig.userContentController = webviewController
        self.webview = WKWebView(frame: UIScreen.main.bounds ,configuration: webviewConfig)
        self.startRequest(cookies: cookies)
    }
    
    func startRequest(cookies:String){
        webview = WKWebView(frame: UIScreen.main.bounds)
        webview.navigationDelegate = self
        webview.tag = 1
        let url = NSURL(string: "https://alumni.nfls.io/" + in_url)!
        let request = NSMutableURLRequest(url: url as URL)
        request.addValue(cookies, forHTTPHeaderField: "Cookie")
        webview.load(request as URLRequest)
        stackView.addArrangedSubview(webview)
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if(navigationAction.request.allHTTPHeaderFields?["Cookie"] == nil){
            decisionHandler(.cancel)
            let request = navigationAction.request as! NSMutableURLRequest
            request.addValue(requestCookies, forHTTPHeaderField: "Cookie")
            webView.load(request as URLRequest)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let url = webView.url?.absoluteString
        let realUrl = webView.url!
        if(!url!.hasPrefix("https://alumni.nfls.io")){
            webView.stopLoading()
            //webView.goBack()
            if(url!.hasPrefix("https://center.nfls.io")){
                tabBarController?.selectedIndex = 1
            } else if(url!.contains("nfls.io")){
                (tabBarController?.navigationController?.viewControllers[(tabBarController?.navigationController!.viewControllers.count)! - 2] as! NewsViewController).handleUrl = url!
                tabBarController?.navigationController?.popViewController(animated: true)
            } else {
                let alert = SCLAlertView()
                alert.addButton("好的", action: {
                    UIApplication.shared.openURL(realUrl)
                })
                alert.showInfo("外部链接", subTitle: "您即将以系统浏览器访问该外部链接："+url!, closeButtonTitle: "取消")
            }
        }
    }
}
