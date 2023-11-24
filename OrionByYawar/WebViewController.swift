//
//  BrowserVC.swift
//  OrionByYawar
//
//  Created by Yawer Khan on 22/11/23.
//

import UIKit
import WebKit
import SafariServices
import Zip

class WebViewController: UIViewController, SFSafariViewControllerDelegate {
    private var webViewArray: [WKWebView] = []
    private var browseHistoryArray: [URL] = []
    private var folderUrl: URL?
    @IBOutlet weak var tabCount: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var webviewCOntainer: UIView!
    @IBOutlet weak var actionsContailer: UIView!
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        createWebView(urlString: "https://addons.mozilla.org/en-US/firefox/addon/top-sites-button/")
      
    }
    
    func createWebView(urlString: String){
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webviewCOntainer.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: webviewCOntainer.topAnchor),
            webView.leadingAnchor.constraint(equalTo: webviewCOntainer.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: webviewCOntainer.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: webviewCOntainer.bottomAnchor)
        ])
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        view.bringSubviewToFront(actionsContailer)
        webView.navigationDelegate = self
        webViewArray.append(webView)
        addBtn.setTitle("\(webViewArray.count-1)", for: .normal)
    }
    
    @IBAction func addNewTabClicked(_ sender: Any) {
        createWebView(urlString: "https://www.google.com")
    }
    
    @IBAction func deleeClicked(_ sender: Any) {
        webViewArray.last?.removeFromSuperview()
        webViewArray.removeLast()
        addBtn.setTitle("\(webViewArray.count-1)", for: .normal)
    }
    
    @IBAction func goBackClicked(_ sender: Any) {
        webViewArray.last?.goBack()
    }
    
    func showAlert() {
            let alertController = UIAlertController(title: "Alert", message: "Click Add to Orion to install extention", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    
    @IBAction func tabCouctClicked(_ sender: Any) {
        guard let url = folderUrl else {
            showAlert()
            return
        }
        let panelJSPath = url.appendingPathComponent("popup/panel.js")
        if FileManager.default.fileExists(atPath: url.path) {
                    if let panelJSContents = try? String(contentsOf: panelJSPath) {
                        webViewArray.last?.evaluateJavaScript(panelJSContents, completionHandler: { (result, error) in
                        if let error = error {
                            print("\(error)")
                        } else {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let topSitesVC = storyboard.instantiateViewController(withIdentifier: "topsitesVC") as! TopsitesVC
                            topSitesVC.data = self.browseHistoryArray
                            self.present(topSitesVC, animated: true, completion: nil)
                        }
                        })
                    } else {
                        print("Failed to read panel.js")
                    }
                }
    }
}

extension WebViewController:WKNavigationDelegate{
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(webView.url?.absoluteString)
        guard let url = webView.url else {
            return
        }
        browseHistoryArray.append(url)
        let javascript = """
                    var buttons = document.getElementsByClassName('Button--action GetFirefoxButton-button');
                    for (var i = 0; i < buttons.length; i++) {
                        if (buttons[i].textContent.includes('Download Firefox and get the extension')) {
                            buttons[i].textContent = 'Add to Orion';
                            break;
                        }
                    }
                """
            webView.evaluateJavaScript(javascript, completionHandler: nil)
        }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated {
        if url.absoluteString.contains("mozilla.org/firefox/download") {
            customFunc()
            decisionHandler(.cancel)
            return
            }
        }
        decisionHandler(.allow)
    }
    
    func customFunc() {
        let javascript = "document.querySelector('.InstallButtonWrapper-download-link').getAttribute('href');"
        webViewArray.last?.evaluateJavaScript(javascript) { (result, error) in
            if let downloadLink = result as? String {
                self.downloadAndCheckFile(urlString: downloadLink)
            }
        }
    }
    
    func downloadAndCheckFile(urlString:String) {
        guard let fileURL = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent("downloadedFile.zip")
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            checkUnzippedFolder(zipURL: destinationURL)
            return
        }
        let downloadTask = URLSession.shared.downloadTask(with: fileURL) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                do {
                    try FileManager.default.moveItem(at: tempLocalUrl, to: destinationURL)
                    self.folderUrl = try Zip.quickUnzipFile(destinationURL)
                    
                    
                } catch {
                    print("\(error)")
                }
            }
        }
        downloadTask.resume()
    }
    
    func checkUnzippedFolder(zipURL: URL) {
        do {
            let unzipDirectory = try Zip.quickUnzipFile(zipURL)
            let localiseJSPath = unzipDirectory.appendingPathComponent("localise.js")
            if FileManager.default.fileExists(atPath: localiseJSPath.path) {
                self.folderUrl = unzipDirectory
            } else {
                print("localise.js not there")
            }
        } catch {
            print("\(error)")
        }
    }
    
    
}

extension WebViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if var text = textField.text, !webViewArray.isEmpty {
            if !text.lowercased().hasPrefix("http://") && !text.lowercased().hasPrefix("https://") {
                text = "https://www." + text
            }
            let lastWebView = webViewArray.last!
            lastWebView.navigationDelegate = self
            let request = URLRequest(url: URL(string: text)!)
            lastWebView.load(request)
        }
        textField.resignFirstResponder()
        return true
    }
}
