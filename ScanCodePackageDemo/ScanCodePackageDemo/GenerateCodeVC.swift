//
//  ScanVC.swift
//  ScanCodePackageDemo
//
//  Created by hqfy on 2024/1/24.
//

import UIKit

/***************生成二维码、条形码*************/
class GenerateCodeVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        backBtn()
        
        //生成二维码
        QRImageView()
        //生成条形码
        barCodeImageView()
    }
    func backBtn() {
        //返回按钮
        let backBtn = UIButton()
        backBtn.backgroundColor = .gray
        backBtn.frame = CGRect(x: 20, y: 64, width: 30, height: 30)
        backBtn.setBackgroundImage(getBundleImage(name: "scan_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        view.addSubview(backBtn)
    }
    @objc func backClick(){
        self.dismiss(animated: true)
    }
    
    
    func QRImageView(){
        //生成二维码
        let image =  generateQRCodeImage(content: "生成二维码的内容8993847349",size: CGSize(width: 200, height: 200), codeType: "CIQRCodeGenerator",codeColor: .green,bgColor: .white)
        let imageView = UIImageView(image: image)
        imageView.frame = CGRectMake(0, 0, 200, 200)
        imageView.center = CGPoint(x: view.center.x, y: 300)
        view.addSubview(imageView)
    }
    
    func barCodeImageView(){
        //生成条形码
        let image =  generateBarCodeImage(content: "7928347957wjer",codeType: "CICode128BarcodeGenerator")
        //缩放图片大小
        if let img = image {
            
            let resizeImage = resizeImage(image: img, quality: .none, rate: 2)
            let imageView = UIImageView(image: resizeImage)
            imageView.frame = CGRectMake(0, 0, 200, 50)
            imageView.center = CGPoint(x: view.center.x, y: 500)
            view.addSubview(imageView)
        }
    }
}
