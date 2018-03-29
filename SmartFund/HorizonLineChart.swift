//
//  HorizonLineChart.swift
//  SmartFund
//
//  Created by jansen_fan on 2018/3/22.
//  Copyright © 2018年 jansen_fan. All rights reserved.
//


import UIKit
import Alamofire
import Charts

class HorizonLineChart: UIViewController {
    
    @IBOutlet weak var horizonLineChart: LineChartView!
    
    var fundCode:String!
    var horizonDateArray:[String]!
    var horizonPriceArray:[String]!
    
    let appDelegate=UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.blockRotation=true
        horizonLineChart.delegate=self
        var valueArray:[Double]=[]
        for i in horizonPriceArray{
            valueArray.append(Double(i)!)
        }
        self.setChart(days: self.horizonDateArray.reversed(), values: valueArray.reversed())
        
    }
    
    ///
    override func viewWillAppear(_ animated: Bool) {
        let value=UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    override func viewWillDisappear(_ animated: Bool) {
        appDelegate.blockRotation=false
        let value=UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    
    func setChart(days:[String],values:[Double]){
        var dataEntries:[ChartDataEntry]=[]
        for i in 0..<days.count {
            let dataEntry=ChartDataEntry(x: Double(i), y: values[i])
            //let dataEntry2=
            dataEntries.append(dataEntry)
        }
        let chartDataSet2:LineChartDataSet=LineChartDataSet(values: dataEntries, label: "时间轴")
        chartDataSet2.setCircleColor(UIColor.red)
        chartDataSet2.circleRadius=1
        chartDataSet2.circleHoleColor=UIColor.red
        
        
        let chartData2:LineChartData=LineChartData(dataSets: [chartDataSet2])
        
        horizonLineChart.data=chartData2
        
        horizonLineChart.chartDescription?.text="PE视图"
        //设置X轴坐标值
        let formatter=IndexAxisValueFormatter(values: days)
        //formatter.numstyle
        //formatt
        horizonLineChart.xAxis.valueFormatter=formatter
        
        horizonLineChart.xAxis.labelPosition = .bottom
        horizonLineChart.xAxis.axisLineWidth=1.0
        horizonLineChart.xAxis.drawLabelsEnabled=true
        horizonLineChart.xAxis.drawGridLinesEnabled=false
        horizonLineChart.xAxis.centerAxisLabelsEnabled=true
        horizonLineChart.xAxis.valueFormatter=IndexAxisValueFormatter(values: days)
        //formatter 对 days进行处理
        
        //设置Y轴坐标
        horizonLineChart.rightAxis.enabled=false
        horizonLineChart.leftAxis.axisLineWidth=1.0
        horizonLineChart.leftAxis.axisLineColor=UIColor.black
        horizonLineChart.scaleYEnabled=false
        
        horizonLineChart.backgroundColor=UIColor.gray
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension HorizonLineChart:ChartViewDelegate{
    
}

