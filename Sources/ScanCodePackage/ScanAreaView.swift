//
//  ScanAreaView.swift
//  ScanCodePackageDemo
//
//  Created by hqfy on 2024/1/22.
//

import UIKit

//扫码视图参数配置
public struct ScanViewStyle {
    //扫码区域类型，默认为矩形框内识别
    var scanAreaStyle:ScanAreaStyle = .angle
    //是否显示绘制矩形框。默认true
    var isShowRetangle = true
    //区域宽高比，默认为1.0，即为正方形
    var whRatio:CGFloat = 1.0
    //矩形框中心偏移量，0为正中心位置
    var centerUpOffset:CGFloat = 0
    //矩形框左边距
    var retangleOffsetX:CGFloat = 60
    //矩形框线条颜色，默认为白色
    var retangleLineColor: UIColor = .white
    //矩形框宽度，默认为1.0
    var retangleLineWidth: CGFloat = 1.0
    //扫码框四个角类型
    var angleStyle:ScanFrameAngleStyle = .on
    //扫码框四个角颜色
    var angleColor:UIColor = UIColor(red: 0.0, green: 167.0 / 255.0, blue: 231.0 / 255.0, alpha: 1.0)
    //扫码框四个角宽高
    var angleW: CGFloat = 24.0
    var angleH: CGFloat = 24.0
    //扫码四个角线条宽度
    var frameLineW: CGFloat = 4
    //扫描动画类型
    var animationStyle: ScanAnimationStyle = .lineMove
    //动画视图
    var animationImageView:UIImageView?
    //非扫码区域背景颜色
    var backgroundAreaColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    
    init() { }
}


open class ScanAreaView: UIView {
    //创建扫码区域默认配置
    public var viewStyle = ScanViewStyle()
    //扫码区域坐标
    public var scanAreaRect: CGRect = .zero
    //加载视图
    public var loadingView: UIActivityIndicatorView?
    //加载label
    public var loadingLab: UILabel?
    //提示文本lab
    public lazy var tipLabel: UILabel = {
        let tipLab = UILabel()
        tipLab.text = "对准二维码区域扫描，识别信息"
        tipLab.textColor = .white
        tipLab.font = .systemFont(ofSize: 14)
        tipLab.textAlignment = .center
        addSubview(tipLab)
        return tipLab
    }()
           
    
    init(frame: CGRect, viewStyle:ScanViewStyle) {
        self.viewStyle = viewStyle

        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    override init(frame: CGRect) {

        super.init(frame: frame)
        backgroundColor = .clear
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   private func addTipLabel(){

        let maxY = (viewStyle.scanAreaStyle == .screen) ? bounds.height * 3.2/5.0 + 15 : scanAreaRect.maxY + 15
        tipLabel.frame = CGRect(x: 0, y: maxY, width: frame.width, height: 25)
    }
    
    private func addScanAnimation(){
        
        if viewStyle.animationStyle == .none { return }
        
        let imageview = viewStyle.animationImageView
        var animationRect = scanAreaRect
        if viewStyle.scanAreaStyle == .screen {
            animationRect = CGRect(x: 0, y: bounds.height/5.0, width: bounds.width, height: bounds.height * 2.2/5.0)
        }
                 
        imageview?.frame = CGRect(origin: animationRect.origin, size: CGSize(width: animationRect.size.width, height: 12))

        ScanAnimation.shared.scanAnimation(animationRect, self, imageView: imageview, style: viewStyle.animationStyle)
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)

        if viewStyle.scanAreaStyle == .angle {
            
            drawScanArea()
        }else{
            UIColor.black.withAlphaComponent(0.2).setFill()
            UIRectFill(rect)
            
            addScanAnimation()
            addTipLabel()
        }
    }
    
    private func drawScanArea(){
        
        let retangleLeft = viewStyle.retangleOffsetX
        var retangleSize = CGSize(width: frame.size.width - retangleLeft * 2.0, height: frame.size.width - retangleLeft * 2.0)
        
        if viewStyle.whRatio != 1.0 {
            let w = retangleSize.width
            var h = w / viewStyle.whRatio
            h = CGFloat(Int(h))
            retangleSize = CGSize(width: w, height: h)
        }
        //扫描区域Y轴最小坐标
        let retangleMinY = frame.size.height / 2.0 - retangleSize.height / 2.0 - viewStyle.centerUpOffset
        let retangleMaxY = retangleMinY + retangleSize.height
        let retangleRight = frame.size.width - retangleLeft

        guard let context = UIGraphicsGetCurrentContext() else { return }
        //背景区域颜色设置
        context.setFillColor(viewStyle.backgroundAreaColor.cgColor)
        //扫码区域填充
        var rect = CGRect(x: 0, y: 0, width: frame.size.width, height: retangleMinY)
        context.fill(rect)
        //扫码区域左边填充
        rect = CGRect(x: 0, y: retangleMinY, width: retangleLeft, height: retangleSize.height)
        context.fill(rect)
        //扫码区域右边填充
        rect = CGRect(x: retangleRight, y: retangleMinY, width: retangleLeft, height: retangleSize.height)
        context.fill(rect)
        //扫码区域下面填充
        rect = CGRect(x: 0, y: retangleMaxY, width: frame.size.width, height: frame.size.height - retangleMaxY)
        context.fill(rect)
        //执行绘画
        context.strokePath()
        
        if viewStyle.isShowRetangle {
            context.setStrokeColor(viewStyle.retangleLineColor.cgColor)
            context.setLineWidth(viewStyle.retangleLineWidth)
            context.addRect(CGRect(x: retangleLeft, y: retangleMinY, width: retangleSize.width, height: retangleSize.height))
            context.strokePath()
        }
        
        scanAreaRect = CGRect(x: retangleLeft, y: retangleMinY, width: retangleSize.width, height: retangleSize.height)
        
        //线的宽度
        let angleLinewidth = viewStyle.frameLineW
        //线条和矩形角间距
        var diffAngle:CGFloat = 0
        
        switch viewStyle.angleStyle {
        case .outer:diffAngle = angleLinewidth / 3 //在矩形框内
        case .inner: diffAngle = -viewStyle.frameLineW / 2 //框外面4个角，与框有缝隙
        case .on:diffAngle = 0 //与矩形框重合
        }
        
        context.setStrokeColor(viewStyle.angleColor.cgColor)
        context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        context.setLineWidth(angleLinewidth)
        
        let left = retangleLeft - diffAngle
        let top = retangleMinY - diffAngle
        let right = retangleRight + diffAngle
        let bottom = retangleMaxY + diffAngle
        //区域角的宽高
        let angleW = viewStyle.angleW
        let angleH = viewStyle.angleH
        //左上角水平线
        context.move(to: CGPoint(x: left - angleLinewidth / 2, y: top))
        context.addLine(to: CGPoint(x: left + angleW, y: top))
        //左上角垂直线
        context.move(to: CGPoint(x: left, y: top - angleLinewidth / 2))
        context.addLine(to: CGPoint(x: left, y: top + angleH))
        //左下角垂水平线
        context.move(to: CGPoint(x: left - angleLinewidth / 2, y: bottom))
        context.addLine(to: CGPoint(x: left + angleW, y: bottom))
        //左下角垂直线
        context.move(to: CGPoint(x: left, y: bottom + angleLinewidth / 2))
        context.addLine(to: CGPoint(x: left, y: bottom - angleH))
        //右上角水平线
        context.move(to: CGPoint(x: right + angleLinewidth / 2, y: top))
        context.addLine(to: CGPoint(x: right - angleW, y: top))
        //右上角垂直线
        context.move(to: CGPoint(x: right, y: top - angleLinewidth / 2))
        context.addLine(to: CGPoint(x: right, y: top + angleH))
        //右下角水平线
        context.move(to: CGPoint(x: right + angleLinewidth / 2, y: bottom))
        context.addLine(to: CGPoint(x: right - angleW, y: bottom))
        //右下角垂直线
        context.move(to: CGPoint(x: right, y: bottom + angleLinewidth / 2))
        context.addLine(to: CGPoint(x: right, y: bottom - angleH))

        context.strokePath()
        
        addScanAnimation()
        addTipLabel()
    }
    //获取扫码识别区域
    public func getScanAreaRect(viewStyle:ScanViewStyle) -> CGRect {
        if viewStyle.scanAreaStyle == .screen {
            scanAreaRect = CGRect(x: 0, y: bounds.height/5.0, width: bounds.width, height: bounds.height * 2.2/5.0)
            return scanAreaRect
        }
        let retangleLeft = viewStyle.retangleOffsetX
        var retangleSize = CGSize(width: frame.size.width - retangleLeft * 2.0, height: frame.size.width - retangleLeft * 2.0)
        
        if viewStyle.whRatio != 1.0 {
            let w = retangleSize.width
            var h = w / viewStyle.whRatio
            h = CGFloat(Int(h))
            retangleSize = CGSize(width: w, height: h)
        }
        //扫描区域Y轴最小坐标
        let retangleMinY = frame.size.height / 2.0 - retangleSize.height / 2.0 - viewStyle.centerUpOffset
        
        scanAreaRect = CGRect(x: retangleLeft, y: retangleMinY, width: retangleSize.width, height: retangleSize.height)
        return scanAreaRect
    }
    
    private func getRetangSize() -> CGSize {
        let retangleLeft = viewStyle.retangleOffsetX
        var retangleSize = CGSize(width: frame.size.width - retangleLeft * 2, height: frame.size.width - retangleLeft * 2)
        let w = retangleSize.width
        var h = w / viewStyle.whRatio
        h = CGFloat(Int(h))
        retangleSize = CGSize(width: w, height: h)
        return retangleSize
    }
    //添加加载loading
    public func startLoading(message:String) {
        let retangleLeft = viewStyle.retangleOffsetX
        let retangleSize = getRetangSize()
        
        let retangleMinY = frame.size.height / 2.0 - retangleSize.height / 2.0 - viewStyle.centerUpOffset
        
        //设备启动状态提示
        if loadingView == nil {
            loadingView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            loadingView?.center = CGPoint(x: retangleLeft + retangleSize.width / 2 - 50, y: retangleMinY + retangleSize.height / 2)
            if #available(iOS 13, *) {
                loadingView?.style = .large
            }else{
                loadingView?.style = .white
            }
            loadingView?.color = .white
            addSubview(loadingView!)
            
            let labelRect = CGRect(x: loadingView!.frame.origin.x + loadingView!.frame.size.width + 10, y: loadingView!.frame.origin.y, width: 100, height: 30)
            loadingLab = UILabel(frame: labelRect)
            loadingLab?.text = message
            loadingLab?.backgroundColor = .clear
            loadingLab?.textColor = .white
            loadingLab?.font = .systemFont(ofSize: 15.0)
            addSubview(loadingLab!)
        }
        loadingView?.startAnimating()
    }
    
    public func stopLoading(){
        if loadingView != nil {
            loadingView?.stopAnimating()
            loadingView?.removeFromSuperview()
            loadingLab?.removeFromSuperview()
            
            loadingView = nil
            loadingLab = nil
        }
    }
    deinit {
        ScanAnimation.shared.stopAnimation()
    }
}

public extension ScanAreaView {
    func getScanAreaForAnimation() -> CGRect {
        let retangleLeft = viewStyle.retangleOffsetX
        
        var retangleSize = CGSize(width: frame.width, height: frame.height)
        
        if viewStyle.whRatio != 1 {
            let w = retangleSize.width
            var h = w / viewStyle.whRatio
            h = CGFloat(Int(h))
            retangleSize = CGSize(width: w, height: h)
        }
        
        let retangleMinY = frame.height / 2.0 - retangleSize.height / 2.0 - viewStyle.centerUpOffset
        
        let cropRect = CGRect(x: retangleLeft, y: retangleMinY, width: retangleSize.width, height: retangleSize.height)
        
        return cropRect
    }
}
