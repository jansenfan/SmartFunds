//
//  LineChart.swift
//  SmartFund
//
//  Created by jansen_fan on 2018/3/22.
//  Copyright © 2018年 jansen_fan. All rights reserved.
//

import UIKit
import Alamofire
import Charts
class LineChart: UIViewController {
    @IBOutlet weak var lineChartView: LineChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        lineChartView.data=chartData2
        
        lineChartView.chartDescription?.text="PE视图"
        //设置X轴坐标值
        let formatter=IndexAxisValueFormatter(values: days)
        //formatter.numstyle
        //formatt
        lineChartView.xAxis.valueFormatter=formatter
        
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.axisLineWidth=1.0
        lineChartView.xAxis.drawLabelsEnabled=true
        lineChartView.xAxis.drawGridLinesEnabled=false
        lineChartView.xAxis.centerAxisLabelsEnabled=true
        lineChartView.xAxis.valueFormatter=IndexAxisValueFormatter(values: days)
        //formatter 对 days进行处理
        
        //设置Y轴坐标
        lineChartView.rightAxis.enabled=false
        lineChartView.leftAxis.axisLineWidth=1.0
        lineChartView.leftAxis.axisLineColor=UIColor.black
        lineChartView.scaleYEnabled=false
        
        lineChartView.backgroundColor=UIColor.gray
        
    }
}
extension LineChart:ChartViewDelegate{
    
}
