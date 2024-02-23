//
//  FirstScanVC.swift
//  ScanCodePackageDemo
//
//  Created by hqfy on 2024/2/2.
//

import UIKit

/*************全自定义扫码视图***************/
class CustomizedScanVC: UIViewController {
   
    //配置类参数
    var scanView: ScanCodeView = ScanCodeView()
    var style: ScanViewStyle = ScanViewStyle()
    var scanImageAction: ScanImageAction  = ScanImageAction()
    
    //相册选择按钮
    var photoBtn: UIButton = UIButton()
    //电筒按钮
    var flashBtn: UIButton = UIButton()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scanView.startSession()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scanView.stopSession()
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        //1.创建扫码视图
        createView()
        //2.添加返回按钮
        addBackBtn()
    }
    
    func createView(){
        
        scanView.frame = view.bounds
        
        style.isShowRetangle = false
        style.whRatio = 0.8
        style.retangleOffsetX = 40
        style.angleW = 10
        style.angleH = 10
        style.backgroundAreaColor = .clear
        style.centerUpOffset = 30
        let imageview = UIImageView()
        imageview.image = getBundleImage(name: "scan_blue_img")
        style.animationImageView = imageview
        scanView.scanStyle = style
        
        //声音文件
        scanView.soundFilePath = "noticeMusic.caf"
        
        //设置自动打开手电筒
        scanView.brightnessChange = { brightValue in
            //注意：系统默认brightValue 只返回小于-1的值，即为黑暗情况
            if brightValue <= -1{
                
                self.scanView.flashModel = .on
            }
        }
        
        scanView.scanDelegate = self
        //开启扫描
        scanView.startScan()
        scanView.scanAreaView.tipLabel.textColor = .orange
        scanView.scanAreaView.tipLabel.text = "提示扫码内容，注意事项"
        view.addSubview(scanView)
        
        //添加自定义按钮
        addMyBtn()
    }
    
    func addMyBtn(){
        let areaRect = scanView.scanAreaView.getScanAreaRect(backView: view, viewStyle: style)
        let btn1 = UIButton()
        btn1.setTitle("自定义按钮1", for: .normal)
        btn1.setTitleColor(.yellow, for: .normal)
        btn1.frame = CGRect(x: (scanView.frame.width - 150)/2.0, y: 120, width: 150, height: 40)
        btn1.addTarget(self, action: #selector(photoAction), for: .touchUpInside)
        scanView.addSubview(btn1)
        
        let btn2 = UIButton()
        btn2.setTitle("自定义按钮2", for: .normal)
        btn2.setTitleColor(.yellow, for: .normal)
        btn2.frame = CGRect(x: (scanView.frame.width - 150)/2.0, y: CGRectGetMaxY(areaRect) + 60, width: 150, height: 40)
        scanView.addSubview(btn2)
    }
    
    @objc func photoAction(){
        scanImageAction.selectPickImage(vc: self)
        scanImageAction.delegate = self

    }
    
    func addBackBtn(){
        let backBtn = UIButton()
        backBtn.frame = CGRect(x: 20, y: 44, width: 30, height: 30)
        backBtn.setBackgroundImage(getBundleImage(name: "scan_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        view.addSubview(backBtn)
    }
    
    @objc func backClick(){
        self.dismiss(animated: true)
    }
}

extension CustomizedScanVC:ScanCodeViewDelegate, ScanImageActionDelegate{
    func scanCodeDidFinished(result: String?, codeType: String) {
        print("扫码结果回调")
    }
    
    func scanImageDidFinished(result: ScanResult?) {
        print("图片码识别结果回调")
    }
}

