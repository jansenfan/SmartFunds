//
//  ViewController.swift
//  SmartFund
//
//  Created by jansen_fan on 2018/3/21.
//  Copyright © 2018年 jansen_fan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyXMLParser
class ViewController: UIViewController {
    let params=GlobalParams()
    @IBOutlet weak var inputCode: UITextField!
    @IBOutlet weak var submitCode: UIButton!
    @IBOutlet weak var allFunds: UITableView!
    
    @IBOutlet weak var corpTable: UITableView!
    //var dateArray:[String]=[]
    //var priceArray:[String]=[]
    
    var indexSelected:String!
    
    var corpSelected:Int=0
    override func viewDidLoad() {
        super.viewDidLoad()
        //Test Area Start
        /*
        let string = "<ResultSet><Result><Hit index=\"1\"><Name>Item1</Name></Hit><Hit index=\"2\"><Name>Item2</Name></Hit></Result></ResultSet>"
        // parse xml document
        let xml = try! XML.parse(string)
        // access xml element
        let accessor = xml["ResultSet"]
        print(accessor)
        print(accessor["Name"])
        print(xml["ResultSet"]["Result"].text)
        print(xml["ResultSet","Result"].text)
        // access XML Text
        if let text = xml["ResultSet", "Result", "Hit", 0, "Name"].text{
            print(text)
            print("exsists path & text in XML Element")
        }
        // access XML Attribute
        if let index = xml["ResultSet", "Result", "Hit"].attributes["index"]{
            print(index)
            print("exsists path & an attribute in XML Element")
        }
        // enumerate child Elements in the parent Element
        for hit in xml["ResultSet", "Result", "Hit"] {
            print(hit)
            print("enumarate existing XML Elements")
        }*/
        
        //Test Area End
        allFunds.delegate=self
        allFunds.dataSource=self
        corpTable.delegate=self
        corpTable.dataSource=self
        
        self.view.backgroundColor=UIColor(displayP3Red: 173/255, green: 216/255, blue: 230/255, alpha: 0.4)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier=="showFund"{
            let controller=segue.destination as! IndexCharts
            controller.fundCode=sender as! String
            let loc=[String](params.ProductList[corpSelected].values).index(of: sender as! String)
            controller.fundName=[String](params.ProductList[corpSelected].keys)[loc!]
        }
    }
    @IBAction func SubmitCode(_ sender: Any) {
        indexSelected=inputCode.text
        if indexSelected.count != 6{
            let alertController=UIAlertController(title: "代码错误", message: "代码长度错误", preferredStyle: .alert)
            let okAction=UIAlertAction(title: "确定", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        var isSuccess=0
        for corp in params.ProductList{
            if [String](corp.values).contains(indexSelected){
                self.performSegue(withIdentifier: "showFund", sender: indexSelected)
                isSuccess=1
            }
        }
        if isSuccess==0{
            let alertController=UIAlertController(title: "代码错误", message: "数据库内无此代码", preferredStyle: .alert)
            let okAction=UIAlertAction(title: "确定", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}


extension ViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if tableView==corpTable{
            corpSelected=indexPath.item
            allFunds.reloadData()
        }
        if tableView==allFunds{
            indexSelected=[String](params.ProductList[corpSelected].values)[indexPath.item]
            self.performSegue(withIdentifier: "showFund", sender: indexSelected)
            
        }
        
    }
}
extension ViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView==corpTable{
            return params.CorpList.count
        }
        if tableView==allFunds{
            return params.ProductList[corpSelected].count
        }
        
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if tableView==allFunds{
            let tempCell=allFunds.dequeueReusableCell(withIdentifier: "reuseCell")
            (tempCell?.viewWithTag(101) as! UILabel).text=[String](params.ProductList[corpSelected].keys)[indexPath.item]
            (tempCell?.viewWithTag(102) as! UILabel).text=[String](params.ProductList[corpSelected].values)[indexPath.item]
            return tempCell!
            
        }
        if tableView==corpTable{
            let tempCell=tableView.dequeueReusableCell(withIdentifier: "corpCell")
            (tempCell?.viewWithTag(51) as! UILabel).text=params.CorpList[indexPath.item]
            return tempCell!
            
        }
        return UITableViewCell()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
}
