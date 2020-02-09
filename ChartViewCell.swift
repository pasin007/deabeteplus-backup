//
//  ChartViewCell.swift
//  deabeteplus
//
//  Created by pasin on 9/2/2563 BE.
//  Copyright © 2563 Ji Ra. All rights reserved.
//

import UIKit
import SwiftCharts

class ChartViewCell: UITableViewCell, BaseViewCell {

    enum ChartType: Int {
        case cal = 0, weight, bmi
        
        var yTitle: String {
            switch self {
            case .cal: return "Kcal"
            case .weight: return "น้ำหนัก (ก.ก.)"
            case .bmi: return "BMI"
            }
        }
        
        var xTitle: String {
            switch self {
            case .cal: return "Day"
            case .weight, .bmi: return "Month"
            }
        }
        
        var title: String {
            switch self {
            case .cal: return "ปริมาณแคลอรี่ล่าสุด"
            case .weight: return "น้ำหนักปัจจุบัน"
            case .bmi: return "ค่า BMI ปัจจุบัน"
            }
        }
        
        var subValue: String {
            switch self {
            case .cal: return "Kcal"
            case .weight: return "ก.ก"
            case .bmi: return ""
            }
        }
    }
    
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var subValueLabel: UILabel!
    
    fileprivate var chart: Chart? // arc
    private var isInit: Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension ChartViewCell {
    
    func configure(_ cals: [Double], type: ChartType,  value: String) {
        titleLabel.text = type.title
        valueLabel.text = value
        subValueLabel.text = type.subValue
        
        guard !isInit else { return }
        isInit = true
        let labelSettings = ChartLabelSettings(font: ChartConfigure.labelFont)
        
        var calArray:[(Int,Int)] = []
        for (idx,cal) in cals.enumerated() {
            calArray.append((idx + 1,Int(cal)))
        }
        
        let chartPoints = calArray.map{ChartPoint(x: ChartAxisValueInt($0.0), y: ChartAxisValueInt($0.1))}
        
        // MARK: - Set Values
        let xValues = ChartAxisValuesStaticGenerator.generateXAxisValuesWithChartPoints(chartPoints, minSegmentCount: 1, maxSegmentCount: 7, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: true)
        let yValues = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 1, maxSegmentCount: 7, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: false)

        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: type.xTitle, settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: type.yTitle, settings: labelSettings.defaultVertical()))
        let chartFrame = ChartConfigure.chartFrame(chartView.bounds)
        
        var chartSettings = ChartConfigure.chartSettings // for now no zooming and panning here until ChartShowCoordsLinesLayer is improved to not scale the lines during zooming.
        chartSettings.trailing = 20
        chartSettings.labelsToAxisSpacingX = 15
        chartSettings.labelsToAxisSpacingY = 15
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let labelWidth: CGFloat = 70
        let labelHeight: CGFloat = 30
                      
        let showCoordsTextViewsGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart) -> UIView? in
            let (chartPoint, screenLoc) = (chartPointModel.chartPoint, chartPointModel.screenLoc)
            let text = chartPoint.description
            let font = ChartConfigure.labelFont
    
            let fontAttributes = [NSAttributedString.Key.font: font]
            let size = NSString(string: text).size(withAttributes: fontAttributes)
                        
            let x = min(screenLoc.x + 5, chart.bounds.width - size.width - 5 )
            let view = UIView(frame: CGRect(x: x, y: screenLoc.y - labelHeight, width: labelWidth, height: labelHeight))
            let label = UILabel(frame: view.bounds)
            label.text = text
            label.font = ChartConfigure.labelFont
            view.addSubview(label)
            view.alpha = 0

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                              view.alpha = 1
            }, completion: nil)
                          
            return view
        }
        
        let showCoordsLinesLayer = ChartShowCoordsLinesLayer<ChartPoint>(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints)
         
         let showCoordsTextLayer = ChartPointsSingleViewLayer<ChartPoint, UIView>(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: showCoordsTextViewsGenerator, mode: .custom, keepOnFront: true)
         // To preserve the offset of the notification views from the chart point they represent, during transforms, we need to pass mode: .custom along with this custom transformer.
         showCoordsTextLayer.customTransformer = {(model, view, layer) -> Void in
             guard let chart = layer.chart else {return}
             
             let text = model.chartPoint.description
           
           let font = ChartConfigure.labelFont
             let fontAttributes = [NSAttributedString.Key.font: font]
             let size = NSString(string: text).size(withAttributes: fontAttributes)
           
           
             let screenLoc = layer.modelLocToScreenLoc(x: model.chartPoint.x.scalar, y: model.chartPoint.y.scalar)
           
             let x = min(screenLoc.x + 5, chart.bounds.width - size.width - 5 )
             
             view.frame.origin = CGPoint(x: x, y: screenLoc.y - labelHeight)
         }
        
        let touchViewsGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart) -> UIView? in
            let (chartPoint, screenLoc) = (chartPointModel.chartPoint, chartPointModel.screenLoc)
            let s: CGFloat = 30
            let view = HandlingView(frame: CGRect(x: screenLoc.x - s/2, y: screenLoc.y - s/2, width: s, height: s))
            view.touchHandler = {[weak showCoordsLinesLayer, weak showCoordsTextLayer, weak chartPoint, weak chart] in
                guard let chartPoint = chartPoint, let chart = chart else {return}
                showCoordsLinesLayer?.showChartPointLines(chartPoint, chart: chart)
                showCoordsTextLayer?.showView(chartPoint: chartPoint, chart: chart)
            }
            return view
        }
        
        let touchLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints, viewGenerator: touchViewsGenerator, mode: .translate, keepOnFront: true)
        
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: .black, lineWidth: 1, animDuration: 0.7, animDelay: 0)
                
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [lineModel])
                      
        let circleViewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart) -> UIView? in
        let circleView = ChartPointEllipseView(center: chartPointModel.screenLoc, diameter: 10)
            circleView.animDuration = 1.5
            circleView.fillColor = UIColor.white
            circleView.borderWidth = 1
            circleView.cornerRadius =  circleView.frame.width / 2
            return circleView
        }
                     
        let chartPointsCircleLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints, viewGenerator: circleViewGenerator, displayDelay: 0, delayBetweenItems: 0.05, mode: .translate)
                      
                   
        let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.black, linesWidth: ChartConfigure.guidelinesWidth)
                    
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: settings)
                      
                      
                    
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                showCoordsLinesLayer,
                chartPointsLineLayer,
                chartPointsCircleLayer,
                showCoordsTextLayer,
                touchLayer,
            ]
        )
                      
        chartView.addSubview(chart.view)
        self.chart = chart
    }
    
}

struct ChartConfigure {
    
    static var chartSettings: ChartSettings {
        return iPhoneChartSettings
    }

    static var chartSettingsWithPanZoom: ChartSettings {
        return iPhoneChartSettingsWithPanZoom
    }
    
    
    fileprivate static var iPhoneChartSettings: ChartSettings {
        var chartSettings = ChartSettings()
        chartSettings.leading = 10
        chartSettings.top = 10
        chartSettings.trailing = 10
        chartSettings.bottom = 10
        chartSettings.labelsToAxisSpacingX = 5
        chartSettings.labelsToAxisSpacingY = 5
        chartSettings.axisTitleLabelsToLabelsSpacing = 4
        chartSettings.axisStrokeWidth = 0.2
        chartSettings.spacingBetweenAxesX = 8
        chartSettings.spacingBetweenAxesY = 8
        chartSettings.labelsSpacing = 0
        return chartSettings
    }


    fileprivate static var iPhoneChartSettingsWithPanZoom: ChartSettings {
        var chartSettings = iPhoneChartSettings
        chartSettings.zoomPan.panEnabled = true
        chartSettings.zoomPan.zoomEnabled = true
        return chartSettings
    }
    
    static func chartFrame(_ containerBounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 70, width: containerBounds.size.width, height: containerBounds.size.height - 70)
    }
    
    static var labelSettings: ChartLabelSettings {
        return ChartLabelSettings(font: ChartConfigure.labelFont)
    }
    
    static var labelFont: UIFont {
        return ChartConfigure.fontWithSize(11)
    }
    
    static var labelFontSmall: UIFont {
        return ChartConfigure.fontWithSize(10)
    }
    
    static func fontWithSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Kodchasan", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static var guidelinesWidth: CGFloat {
        return 0.1
    }
    
    static var minBarSpacing: CGFloat {
        return 5
    }
}
