//
//  TopsitesVC.swift
//  OrionByYawar
//
//  Created by Yawer Khan on 24/11/23.
//

import UIKit

class TopsitesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var data:[URL] = []
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableview.dataSource = self
        self.tableview.delegate = self
        
        self.registerTableViewCells()
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ToSitesTVC") as? ToSitesTVC {
            cell.lbl.text = data[indexPath.row].absoluteString
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    private func registerTableViewCells() {
        let textFieldCell = UINib(nibName: "ToSitesTVC",
                                  bundle: nil)
        self.tableview.register(textFieldCell,
                                forCellReuseIdentifier: "ToSitesTVC")
    }
}



