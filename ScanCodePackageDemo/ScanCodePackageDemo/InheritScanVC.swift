//
//  SecondScanVC.swift
//  ScanCodePackageDemo
//
//  Created by hqfy on 2024/2/2.
//

import UIKit

/***********继承ScanBaseVC的修改样式扫码视图***********/
class InheritScanVC: ScanBaseVC {

    override func viewDidLoad() {
        style.angleColor = .red
        style.whRatio = 0.6
        style.angleW = 10
        style.angleH = 30
        style.angleStyle = .outer
        style.animationImageView = UIImageView(image: getBundleImage(name: "scan_gride_img"))
        style.animationStyle = .grid
        style.retangleLineColor = .green
        super.viewDidLoad()
        
        scanTitle.text = "扫一扫"
        scanTitle.textColor = .red
        let scanRect = scanView.scanAreaView.getScanAreaRect(backView: view, viewStyle: style)
        
        //修改按钮位置
        photoBtn.frame = CGRect(x: scanRect.origin.x, y: 120, width: 40, height: 40)
        getCodeBtn.frame = CGRect(x: CGRectGetMaxX(scanRect) - 30, y: 120, width: 30, height: 30)
        delegate = self
        
        setGenerateCodeConfig(content: "添加二维码生成的内容",size: CGSize(width: 100, height: 100),codeType: "CIQRCodeGenerator",codeColor: .blue,bgColor: .white)
    }
}

extension InheritScanVC:ScanBaseVCDelegate {
    func scanCodeBaseDidFinished(result: String?, codeType: String) {
        print("扫码结果")
    }
    func scanImageBaseDidFinished(result: ScanResult?) {
        print("识别图片结果")
    }
    func scanGenerateCodeImage(image: UIImage?) {
        print("生成二维码图片")
    }
}
