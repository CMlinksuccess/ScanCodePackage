//
//  ScanBaseVC.swift
//  ScanCodePackageDemo
//
//  Created by hqfy on 2024/1/26.
//

import UIKit

 protocol ScanBaseVCDelegate:NSObjectProtocol{
    
    //扫码完成的回调
    func scanCodeBaseDidFinished(result:String?,codeType:String)
    //识码结果回调
    func scanImageBaseDidFinished(result:ScanResult?)
    //生成二维码图片结果回调
    func scanGenerateCodeImage(image:UIImage?)
}

class ScanBaseVC: UIViewController {
    //配置类参数
    var scanView: ScanCodeView = ScanCodeView()
    var style: ScanViewStyle = ScanViewStyle()
    var scanImageAction: ScanImageAction  = ScanImageAction()
    
    weak var delegate:ScanBaseVCDelegate?
    
    //相册选择按钮
    var photoBtn: UIButton = UIButton()
    //电筒按钮
    var flashBtn: UIButton = UIButton()
    //生成二维码/条形码按钮
    var getCodeBtn: UIButton = UIButton()
    //是否显示标题
    var isShowTitle:Bool = true
    
    lazy var scanTitle: UILabel = {
    
        let titleLab = UILabel()
        titleLab.frame = CGRect(x: 0, y: 44, width: view.frame.width, height: 40)
        titleLab.text = "扫一扫"
        titleLab.textColor = .white
        titleLab.textAlignment = .center
        titleLab.font = .boldSystemFont(ofSize: 18)
        view.addSubview(titleLab)
        
        return titleLab
    }()
    
    //生成二维码时的参数配置
    private var content:String?
    private var size:CGSize = CGSize(width: 50, height: 50)
    private var codeType:String = "CIQRCodeGenerator"
    private var codeColor:UIColor = .black
    private var bgColor:UIColor = .white
    func setGenerateCodeConfig(content:String, size:CGSize = CGSize(width: 50, height: 50),codeType:String = "CIQRCodeGenerator",codeColor:UIColor = .black, bgColor:UIColor = .white) {
        self.content = content
        self.size = size
        self.codeType = codeType
        self.codeColor = codeColor
        self.bgColor = bgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //创建扫码界面
        createScanView()
        //是否添加标题
        if isShowTitle {view.addSubview(scanTitle)}
        //返回按钮
        let backBtn = UIButton()
        backBtn.frame = CGRect(x: 20, y: 44, width: 30, height: 30)
        //UIImage(named: "scanResource.bundle/scan_back")
        backBtn.setBackgroundImage(getBundleImage(name: "scan_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        view.addSubview(backBtn)
    }
    @objc func backClick(){
        self.dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scanView.startSession()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scanView.stopSession()
    }
    //创建扫码视图
    private func createScanView() {

        if style.animationImageView == nil {
            let imageview = UIImageView()
            if style.animationStyle == .lineMove {
                imageview.image = getBundleImage(name: "scan_blue_img")
                

            }else if style.animationStyle == .grid{
                imageview.image = getBundleImage(name: "scan_gride_img")
            }
            style.animationImageView = imageview
        }
        scanView.frame = view.bounds
        scanView.scanStyle = style
        //声音文件
        scanView.soundFilePath = "noticeMusic.caf"
        //开启扫描
        scanView.startScan()
        view.addSubview(scanView)
        
        //添加图片识别二维码按钮
        createPhotoImageButton()
        //添加闪光灯按钮
        createFlashButton()
        //添加生成二维码
        createGetCodeButton()
    }
    //创建图片识码按钮
    private func createPhotoImageButton(){
        let scanRect = scanView.scanAreaView.getScanAreaRect(backView: view, viewStyle: style)
        photoBtn.frame = CGRect(x: scanRect.origin.x, y: CGRectGetMaxY(scanRect) + 100, width: 40, height: 40)
        photoBtn.setBackgroundImage(getBundleImage(name: "photo_img"), for: .normal)
        photoBtn.addTarget(self, action: #selector(photoImageAction), for: .touchUpInside)
        scanView.addSubview(photoBtn)
    }
    
    @objc private func photoImageAction() {
        scanImageAction.selectPickImage(vc: self)
        scanImageAction.delegate = self
    }
    //创建手电筒
    private func createFlashButton(){
        let scanRect = scanView.scanAreaView.getScanAreaRect(backView: view, viewStyle: style)
        flashBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 40)
        flashBtn.center = CGPoint(x: view.center.x, y: CGRectGetMaxY(scanRect) + 70)
        flashBtn.setBackgroundImage(getBundleImage(name: "flash_off"), for: .normal)
        flashBtn.setBackgroundImage(getBundleImage(name: "flash_on"), for: .selected)
        flashBtn.addTarget(self, action: #selector(flashAction(btn:)), for: .touchUpInside)
        scanView.addSubview(flashBtn)
        
        //设置自动显示手电筒
        scanView.brightnessChange = { brightValue in
            //注意：系统默认brightValue 只返回小于-1的值，即为黑暗情况
            if !self.flashBtn.isSelected {
                
                self.flashBtn.isHidden = brightValue > -1
            }
        }
    }
    
    @objc private func flashAction(btn:UIButton){
        btn.isSelected = !btn.isSelected
        
        if btn.isSelected {
            scanView.flashModel = .on
        }else{
            scanView.flashModel = .off
        }
    }
    //创建生成二维码按钮
    private func createGetCodeButton(){
        let scanRect = scanView.scanAreaView.getScanAreaRect(backView: view, viewStyle: style)
        getCodeBtn.frame = CGRect(x: CGRectGetMaxX(scanRect) - 35, y: CGRectGetMaxY(scanRect) + 100, width: 35, height: 35)
        getCodeBtn.setBackgroundImage(getBundleImage(name: "getcode_img"), for: .normal)
        getCodeBtn.addTarget(self, action: #selector(getCodeAction), for: .touchUpInside)
        scanView.addSubview(getCodeBtn)
    }
    
    @objc private func getCodeAction() {
        
        if let del = delegate,let con = content {
            let image = generateQRCodeImage(content: con, size: size, codeColor: codeColor, bgColor: bgColor)
            del.scanGenerateCodeImage(image: image)
        }
    }
}

extension ScanBaseVC: ScanImageActionDelegate,ScanCodeViewDelegate {
    func scanCodeDidFinished(result: String?, codeType: String) {
        //扫描二维码结果
        if let del = delegate {
            del.scanCodeBaseDidFinished(result: result, codeType: codeType)
        }
    }
    func scanImageDidFinished(result: ScanResult?) {
        //图片扫码结果
        if let del = delegate {
            del.scanImageBaseDidFinished(result: result)
        }
    }
}
