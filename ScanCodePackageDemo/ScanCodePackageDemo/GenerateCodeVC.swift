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
      
        let imageView = UIImageView()
        imageView.frame = CGRectMake(0, 0, 150, 150)
        imageView.center = CGPoint(x: view.center.x, y: 200)
        view.addSubview(imageView)
        
     
        
        let newImageView = UIImageView()
        newImageView.frame = CGRectMake(0, 0, 150, 150)
        newImageView.center = CGPoint(x: view.center.x, y: 400)
        view.addSubview(newImageView)
        
        //生成二维码
        generateQRCodeImage(content: "这是生成二维码的内容8993847349- https://pay-tw.blustargames.com/token/payData?param=tag:buyFail,data:gameID:3061,channel:1045,extend:345678987654;3;2;1045;20,amount:9.99,deviceType:0,uid:345678987654,productID:s.sea.rhs.03,openid:306101a1516371731596644352,appOrderID:2204201500106560394,bundleID:com.blustar.projects.ios,productIdentifier:s.sea.rhs.03 https://pay-tw.blustargames.com/token/payData?param=tag:buyFail,data:gameID:3061,channel:1045,extend:345678987654;3;2;1045;20,amount:9.99,deviceType:0,uid:345678987654,productID:s.sea.rhs.03,openid:306101a1516371731596644352,appOrderID:2204201500106560394,bundleID:com.blustar.projects.ios,productIdentifier:s.sea.rhs.03 https://pay-tw.blustargames.com/token/payData?param=tag:buyFail,data:gameID:3061,channel:1045,extend:345678987654;3;2;1045;20,amount:9.99,deviceType:0,uid:345678987654,productID:s.sea.rhs.03,openid:306101a1516371731596644352,appOrderID:2204201500106560394,bundleID:com.blustar.projects.ios,productIdentifier:s.sea.rhs.03 https://pay-tw.blustargames.com/token/payData?param=tag:buyFail,data:gameID:3061,channel:1045,extend:345678987654;3;2;1045;20,amount:9.99,deviceType:0,uid:345678987654,productID:s.sea.rhs.03,openid:306101a1516371731596644352,appOrderID:2204201500106560394,bundleID:com.blustar.projects.ios,productIdentifier:s.sea.rhs.03",size: CGSize(width: 200, height: 200), codeType: "CIQRCodeGenerator",codeColor: .green,bgColor: .white) { image in
            //原图
            imageView.image = image
            
            //添加中心图标
            let newImage =  image?.addQRCenterIcon(UIImage(named: "icon_header"))
            newImageView.image = newImage
        }
    }
    
    func barCodeImageView(){
        //生成条形码
//        let image =  generateBarCodeImage(content: "7928347957wjer",codeType: "CICode128BarcodeGenerator")
        generateBarCodeImage(content: "7928347957wjer",codeType: "CICode128BarcodeGenerator") { image in
            
            //缩放图片大小
            if let img = image {
                
                let resizeImage = resizeImage(image: img, quality: .none, rate: 2)
                let imageView = UIImageView(image: resizeImage)
                imageView.frame = CGRectMake(0, 0, 200, 50)
                imageView.center = CGPoint(x: self.view.center.x, y: 550)
                self.view.addSubview(imageView)
            }
        }
    }
}
