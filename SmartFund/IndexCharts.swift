//
//  IndexCharts.swift
//  SmartFund
//
//  Created by jansen_fan on 2018/3/21.
//  Copyright © 2018年 jansen_fan. All rights reserved.
//

import UIKit
import Alamofire
import Charts
import SwiftyXMLParser

class IndexCharts: UIViewController {
    
    @IBOutlet weak var lineChartView: LineChartView!
    //@IBOutlet weak var fundHistory: UITableView!
    @IBOutlet weak var candleChartView: CandleStickChartView!
    
    var fundCode:String!
    var fundName:String!
    
    @IBOutlet weak var fundCodeLabel: UILabel!
    @IBOutlet weak var fundNameLabel: UILabel!
    
    
    
    var http:String!
    
    
    
    var dateArray:[String]=[]
    var priceArray:[String]=[]
    //var dateWeekArray:[String]=[]
    //var priceWeekArray:[String]=[]
    
    //Month
    
    var dateWeekArray:[String]=[]
    var priceWeekArray:[String]=[]
    var maxPriceWeekArray:[Double]=[]
    var minPriceWeekArray:[Double]=[]
    var endPriceWeekArray:[Double]=[]
    var startPriceWeekArray:[Double]=[]
    
    //Month
    
    var dateMonthArray:[String]=[]
    var priceMonthArray:[String]=[]
    var maxPriceMonthArray:[Double]=[]
    var minPriceMonthArray:[Double]=[]
    var endPriceMonthArray:[Double]=[]
    var startPriceMonthArray:[Double]=[]
    
    //Year
    var dateYearArray:[String]=[]
    var priceYearArray:[String]=[]
    var maxPriceYearArray:[Double]=[]
    var minPriceYearArray:[Double]=[]
    var endPriceYearArray:[Double]=[]
    var startPriceYearArray:[Double]=[]
    
    
    @IBOutlet weak var dayButton: UIButton!
    
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.present(alert, animated: true, completion: nil)
        http="http://fund.eastmoney.com/f10/F10DataApi.aspx?type=lsjz&code=\(fundCode!)&page=1&per=100000"
        dataFromEastMoney()
        fundCodeLabel.text=fundCode
        fundNameLabel.text=fundName
        //fundHistory.delegate=self
        //fundHistory.dataSource=self
        lineChartView.delegate=self
        candleChartView.delegate=self
        candleChartView.isHidden=true
        
        //self.view.backgroundColor=UIColor(displayP3Red: 173/255, green: 216/255, blue: 230/255, alpha: 0.4)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="toHorizon"{
            let controller=segue.destination as! HorizonLineChart
            controller.horizonDateArray=dateArray
            controller.horizonPriceArray=priceArray
        }
    }
    @IBAction func weekChart(_ sender: Any) {
        /*
        candleChartView.isHidden=true
        lineChartView.isHidden=false
        
        var valueArray:[Double]=[]
        for i in self.priceWeekArray{
            valueArray.append(Double(i)!)
        }
        self.setChart(days: self.dateWeekArray.reversed(), values: valueArray.reversed())*/
        candleChartView.isHidden=false
        lineChartView.isHidden=true
        setHistChart(days:self.dateWeekArray.reversed(),max:self.maxPriceWeekArray.reversed(),min:self.minPriceWeekArray.reversed(),start:self.startPriceWeekArray.reversed(),end:self.endPriceWeekArray.reversed())
        
    }
    @IBAction func monthChart(_ sender: Any) {
        candleChartView.isHidden=false
        lineChartView.isHidden=true
        setHistChart(days:self.dateMonthArray.reversed(),max:self.maxPriceMonthArray.reversed(),min:self.minPriceMonthArray.reversed(),start:self.startPriceMonthArray.reversed(),end:self.endPriceMonthArray.reversed())
    }
    @IBAction func yearChart(_ sender: Any) {
        candleChartView.isHidden=false
        lineChartView.isHidden=true
        setHistChart(days:self.dateYearArray.reversed(),max:self.maxPriceYearArray.reversed(),min:self.minPriceYearArray.reversed(),start:self.startPriceYearArray.reversed(),end:self.endPriceYearArray.reversed())
    }
    
    @IBOutlet weak var monthChart: UIButton!
    
    
    @IBAction func dayChart(_ sender: Any) {
        candleChartView.isHidden=true
        lineChartView.isHidden=false
        var valueDayArray:[Double]=[]
        for i in self.priceArray{
            valueDayArray.append(Double(i)!)
        }
        self.setChart(days: self.dateArray.reversed(), values: valueDayArray.reversed())
    }
    
    func NoDataAlert(){
        let alert=UIAlertController(title: "告警", message: "该基金暂无数据", preferredStyle: .alert)
        let okAction=UIAlertAction(title: "确定", style: .default, handler:{action in
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        })
        print("worked")
        alert.addAction(okAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        
    }
    
    func dataFromEastMoney(){
        Alamofire.request(http).responseString{response in
            self.dateArray=[]
            self.priceArray=[]
            self.dateWeekArray=[]
            self.priceWeekArray=[]
            self.dateMonthArray=[]
            self.priceMonthArray=[]
            self.priceYearArray=[]
            self.dateYearArray=[]
            
            
            
            let html=response.value
            //let xml=try! XML.parse(html!)
            //print(xml.all)
            //print(xml)
            //print(xml.attributes)
            
            let res=html?.components(separatedBy: "<tr>")
            for i in res!{
                let tempArray=i.components(separatedBy: "</td>")
                
                if tempArray.count<2{
                    continue
                }
                let date=tempArray[0].split(separator: ">")[1]
                let price=tempArray[1].split(separator: ">")[1]
                self.dateArray.append(String(date))
                self.priceArray.append(String(price))
            }
            //因为Alamofire的异步行为
            //self.fundHistory.reloadData()
            var valueArray:[Double]=[]
            //无数据警报
            if self.priceArray.count<3{
                self.NoDataAlert()
            }
            else{
                let formattor=DateFormatter()
                formattor.dateFormat="yyyy-MM-dd"
                
                var lastFridayDate:String!
                var lastFridayPrice:String!
                var lastWeek:Int=0
                
                //Week
                
                var tempWeekPriceArray:[Double]=[]
                var tempWeek:Int=0
                var startWeekPrice:Double=0
                self.endPriceWeekArray.append(Double(self.priceArray[0])!)
                
                //Month
                var tempMonthPriceArray:[Double]=[]
                var tempMonth:Int=0
                var startMonthPrice:Double=0
                self.endPriceMonthArray.append(Double(self.priceArray[0])!)
                
                
                //Year
                var tempYearPriceArray:[Double]=[]
                var tempYear:Int=0
                var startYearPrice:Double=0
                self.endPriceYearArray.append(Double(self.priceArray[0])!)
                
                for i in 0..<self.dateArray.count{
                    let range=(self.dateArray[i] as! NSString).range(of: "span")
                    if range.length != 0{
                        continue
                    }
                    let sDate=formattor.date(from: self.dateArray[i])
                    let com=Calendar.current.dateComponents([.weekOfYear,.month,.year], from: sDate!)
                    if tempWeek==0{
                        tempWeek=com.weekOfYear!
                    }
                    if tempYear==0{
                        tempYear=com.year!
                    }
                    if tempMonth==0{
                        tempMonth=com.month!
                    }
                    if i != 0{
                        //周数据处理
                        if com.weekOfYear==tempWeek{
                            tempWeekPriceArray.append(Double(self.priceArray[i])!)
                            startWeekPrice=Double(self.priceArray[i])!
                            if i==(self.dateArray.count-1){
                                self.dateWeekArray.append(self.dateArray[i])
                                self.startPriceWeekArray.append(startWeekPrice)
                                self.maxPriceWeekArray.append(tempWeekPriceArray.max()!)
                                self.minPriceWeekArray.append(tempWeekPriceArray.min()!)
                            }
                        }
                        else{
                            //tempWeekPriceArray
                            if tempWeekPriceArray==[]{
                                self.dateWeekArray.append(self.dateArray[i-1])
                                self.startPriceWeekArray.append(Double(self.priceArray[i-1])!)
                                self.maxPriceWeekArray.append(Double(self.priceArray[i-1])!)
                                self.minPriceWeekArray.append(Double(self.priceArray[i-1])!)
                                self.endPriceWeekArray.append(Double(self.priceArray[i-1])!)
                                
                                tempWeek=com.weekOfYear!
                            }else{
                                
                                self.dateWeekArray.append(self.dateArray[i-1])
                                tempWeek=com.weekOfYear!
                                self.startPriceWeekArray.append(startWeekPrice)
                                self.maxPriceWeekArray.append(tempWeekPriceArray.max()!)
                                self.minPriceWeekArray.append(tempWeekPriceArray.min()!)
                                self.endPriceWeekArray.append(Double(self.priceArray[i])!)
                                tempWeekPriceArray=[]
                                tempWeekPriceArray.append(Double(self.priceArray[i])!)
                                //tempWeek=com.month!
                            }
                        }
                        
                        
                        
                        //月数据处理
                        
                        if com.month==tempMonth{
                            tempMonthPriceArray.append(Double(self.priceArray[i])!)
                            startMonthPrice=Double(self.priceArray[i])!
                            if i==(self.dateArray.count-1){
                                self.dateMonthArray.append(String(tempYear)+String(tempMonth))
                                self.startPriceMonthArray.append(startMonthPrice)
                                self.maxPriceMonthArray.append(tempMonthPriceArray.max()!)
                                self.minPriceMonthArray.append(tempMonthPriceArray.min()!)
                            }
                        }
                        else{
                            //tempMonthPriceArray:当前月份价格数据缓存
                            if tempMonth<10{
                                self.dateMonthArray.append(String(tempYear)+"0"+String(tempMonth))
                            }
                            else{
                                self.dateMonthArray.append(String(tempYear)+String(tempMonth))
                            }
                            
                            tempMonth=com.month!
                            self.startPriceMonthArray.append(startMonthPrice)
                            self.maxPriceMonthArray.append(tempMonthPriceArray.max()!)
                            self.minPriceMonthArray.append(tempMonthPriceArray.min()!)
                            self.endPriceMonthArray.append(Double(self.priceArray[i])!)
                            tempMonthPriceArray=[]
                            tempMonthPriceArray.append(Double(self.priceArray[i])!)
                            tempMonth=com.month!
                        }
                        
                        
                        
                        
                        //年数据处理
                        if com.year==tempYear{
                            tempYearPriceArray.append(Double(self.priceArray[i])!)
                            startYearPrice=Double(self.priceArray[i])!
                            if i==(self.dateArray.count-1){
                                self.dateYearArray.append(String(tempYear))
                                self.startPriceYearArray.append(startYearPrice)
                                self.maxPriceYearArray.append(tempYearPriceArray.max()!)
                                self.minPriceYearArray.append(tempYearPriceArray.min()!)
                            }
                        }
                        else{
                            //tempYearPriceArray:当前年份价格数据缓存
                            self.dateYearArray.append(String(tempYear))
                            tempYear=com.year!
                            self.startPriceYearArray.append(startYearPrice)
                            self.maxPriceYearArray.append(tempYearPriceArray.max()!)
                            self.minPriceYearArray.append(tempYearPriceArray.min()!)
                            self.endPriceYearArray.append(Double(self.priceArray[i])!)
                            tempYearPriceArray=[]
                            tempYearPriceArray.append(Double(self.priceArray[i])!)
                            tempYear=com.year!
                        }
                    }
                    //lastWeek=weekOfYear!
                    //lastFridayDate=self.dateArray[i]
                    //lastFridayPrice=self.priceArray[i]
                }
                
                
                for i in self.priceArray{
                    valueArray.append(Double(i)!)
                }
                self.setChart(days: self.dateArray.reversed(), values: valueArray.reversed())
                
                
                
                //年华数据验证
                for i in 0..<self.dateArray.count{
                    print(self.dateArray[i])
                    print(self.priceArray[i])
                }
                
                for i in 0..<self.dateYearArray.count{
                    print("年份：\(self.dateYearArray[i])")
                    print("开始价格：\(self.startPriceYearArray[i])")
                    print("最高价格：\(self.maxPriceYearArray[i])")
                    print("最低价格：\(self.minPriceYearArray[i])")
                    print("结束价格：\(self.endPriceYearArray[i])")
                }
                for i in 0..<self.dateWeekArray.count{
                    print("月份：\(self.dateWeekArray[i])")
                    print("开始价格：\(self.startPriceWeekArray[i])")
                    print("最高价格：\(self.maxPriceWeekArray[i])")
                    print("最低价格：\(self.minPriceWeekArray[i])")
                    print("结束价格：\(self.endPriceWeekArray[i])")
                }
            }
        }
    }
    
    func setHistChart(days:[String],max:[Double],min:[Double],start:[Double],end:[Double]){
        candleChartView.backgroundColor = UIColor.white
        // 画板颜色
        candleChartView.gridBackgroundColor = UIColor.clear
        //
        candleChartView.borderColor = UIColor.white
        // 横轴数据
        var xValues=self.dateMonthArray
        
        // 初始化CandleChartDataEntry数组
        var yValues = [CandleChartDataEntry]()
        
        for j in 0..<days.count{
            yValues.append(CandleChartDataEntry.init(x: Double(j), shadowH: max[j], shadowL: min[j], open: start[j], close: end[j]))
        }
        let set1 = CandleChartDataSet.init(values: yValues, label: "单位净值")
        set1.setColor(UIColor.blue)
        set1.shadowColor = UIColor ( red: 0.5536, green: 0.5528, blue: 0.0016, alpha: 1.0 )
        // 立线的宽度
        set1.shadowWidth = 0.7
        // close >= open
        //set1.decreasingColor = UIColor.red
        set1.decreasingColor=UIColor.blue
        // 内部是否充满颜色
        set1.decreasingFilled = true
        // open > close
        
        //set1.increasingColor = UIColor ( red: 0.0006, green: 0.2288, blue: 0.001, alpha: 1.0 )
        set1.increasingColor=UIColor.red
        // 内部是否充满颜色
        set1.increasingFilled = true
        // 赋值数据
        //let data = CandleChartData(xVals: xValues, dataSet: set1)
        let date=CandleChartData.init(dataSets: [set1])
        candleChartView.xAxis.valueFormatter=IndexAxisValueFormatter(values:days)
        candleChartView.xAxis.labelPosition = .bottom
        candleChartView.xAxis.axisLineWidth=1.0
        candleChartView.xAxis.drawLabelsEnabled=true
        candleChartView.xAxis.drawGridLinesEnabled=false
        candleChartView.xAxis.centerAxisLabelsEnabled=true
        candleChartView.rightAxis.enabled=false
        candleChartView.leftAxis.axisLineWidth=1.0
        candleChartView.leftAxis.axisLineColor=UIColor.black
        candleChartView.scaleYEnabled=false
        
        candleChartView.data = date
    }
    
    func setChart(days:[String],values:[Double]){
        var dataEntries:[ChartDataEntry]=[]
        for i in 0..<days.count {
            let dataEntry=ChartDataEntry(x: Double(i), y: values[i])
            //let dataEntry2=
            dataEntries.append(dataEntry)
        }
        let chartDataSet2:LineChartDataSet=LineChartDataSet(values: dataEntries, label: "单位净值")
        chartDataSet2.setCircleColor(UIColor.red)
        chartDataSet2.circleRadius=1
        chartDataSet2.circleHoleColor=UIColor.red
        
        
        
        
        lineChartView.noDataText="加载中"
        
        let chartData2:LineChartData=LineChartData(dataSets: [chartDataSet2])
        
        lineChartView.data=chartData2
        
        lineChartView.chartDescription?.text="PE视图"
        //设置X轴坐标值
        let formatter=IndexAxisValueFormatter(values: days)
        //formatter.numstyle
        //formatt
        //lineChartView.setVisibleXRangeMaximum(100)
        lineChartView.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: UILayoutConstraintAxis.horizontal)
        lineChartView.xAxis.valueFormatter=formatter
        
        
        //lineChartView.setVisibleXRangeMaximum(30)
        //lineChartView.setVisibleXRange(minXRange: 30, maxXRange: 100)
        //lineChartView.xAxis.
        //lineChartView.notifyDataSetChanged()//
        
        
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
        
        //lineChartView.backgroundColor=UIColor.lightGray
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension IndexCharts:ChartViewDelegate{
    
}
