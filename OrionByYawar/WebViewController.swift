//
//  BrowserVC.swift
//  OrionByYawar
//
//  Created by Yawer Khan on 22/11/23.
//

import UIKit
import WebKit
import Zip
import Foundation

class WebViewController: UIViewController {
    private var webViewArray: [WKWebView] = []
    private var browseHistoryArray: [URL] = []
    private var folderUrl: URL?
    private var manifest: Manifest?
    
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
        
    
    }
}

extension WebViewController:WKNavigationDelegate{
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
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

extension WebViewController{
    
    func readJSONFromFile(fileURL:URL) {
        do {
            let path = fileURL.appendingPathComponent("manifest.json")
            let data = try Data(contentsOf: path)
            let decoder = JSONDecoder()
            self.manifest = try decoder.decode(Manifest.self, from: data)
            self.setIconToButton(image: self.manifest?.browser_action?.default_icon?.four_eight ?? "", fileURL: fileURL)
        } catch {
            print("\(error)")
        }
    }
    
    func setIconToButton(image:String, fileURL:URL) {
        let panelJSPath = fileURL.appendingPathComponent(image)
        do {
            let imageData = try Data(contentsOf: panelJSPath)
            let image = UIImage(data: imageData)
            tabCount.setImage(image, for: .normal)
            } catch {
                print(" \(error)")
            }
        }
    
    func checkUnzippedFolder(zipURL: URL) {
        do {
            let unzipDirectory = try Zip.quickUnzipFile(zipURL)
            self.folderUrl = try Zip.quickUnzipFile(zipURL)
            let panelJSPath = unzipDirectory.appendingPathComponent("manifest.json")
            self.readJSONFromFile(fileURL: unzipDirectory)
        } catch {
            print("\(error)")
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
                    let panelJSPath = try Zip.quickUnzipFile(destinationURL).appendingPathComponent("manifest.json")
                    self.readJSONFromFile(fileURL: panelJSPath)
                } catch {
                    print("\(error)")
                }
            }
        }
        downloadTask.resume()
    }
}
