//
//  ScanCodeModel.swift
//  ScanCodePackageDemo
//
//  Created by hqfy on 2024/1/30.
//

import UIKit
import AVFoundation
import Photos

//MARK: 扫码区域类型
public enum ScanAreaStyle {
    case screen //传入视图100%扫描
    case angle  //矩形框区域
}

//MARK: 扫码区域动画类型
public enum ScanAnimationStyle {
    case lineMove  //线条上下移动
    case grid      //网格扫描
    case lineStill //线条停放在中间位置
    case none      //无动画效果
}
//MARK: 扫码区域四角位置类型
public enum ScanFrameAngleStyle {
    case inner //内嵌，一般无矩形框显示效果
    case outer //矩形框角上外嵌
    case on    //矩形框角上覆盖
}

//MARK: 扫描码类型
public enum MetaDataType {
    case allType //所有类型
    case qrType  //二维码类型
    case barType //条形码类型
    case customize(scanType:[AVMetadataObject.ObjectType])//自定义类型
    
    var value: [AVMetadataObject.ObjectType] {
        switch self {
        case .allType:
            return [.aztec,.dataMatrix,.qr,.code128,.code39,.code93,.code39Mod43,.ean8,.ean13,.face,.interleaved2of5,.itf14,.pdf417,.upce]
        case .qrType:
            return [.aztec,.dataMatrix,.qr]
        case .barType:
            return [.code128,.code39,.code93,.code39Mod43,.ean8,.ean13,.face,.interleaved2of5,.itf14,.pdf417,.upce]
        case .customize(let scanType):
            return scanType
        }
    }
}


//MARK: 扫码结果结构，通用型
public struct ScanResult {
    //结果内容
    public var content: String?
    //码的相关信息,不同类型的码信息不同,如：二维码.qr为子类CIQRCodeDescriptor
    public var descriptor:CIBarcodeDescriptor?
    //码类型
    public var codeType: String?
    
    public init(content: String? = nil, descriptor: CIBarcodeDescriptor? = nil, codeType: String? = nil) {
        self.content = content
        self.descriptor = descriptor
        self.codeType = codeType
    }
}

//MARK: 单独二维码识别的结果结构
public struct ScanQRResult {
    //结果内容
    public var content: String?
    //码类型
    public var codeType: String?
    //图片
    public var img: UIImage?
    //码在图像中的位置
    public var positionArr: [AnyObject]?
    
    public init(content: String? = nil, img: UIImage? = nil, codeType: String? = nil, positionArr: [AnyObject]? = nil) {
        self.content = content
        self.img = img
        self.codeType = codeType
        self.positionArr = positionArr
    }
}


//系统权限获取
//MARK: 获取相册权限
public func authorizePhotoStatus(completion:@escaping (Bool) -> Void){
    var status:PHAuthorizationStatus
    if #available(iOS 14, *) {
        status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
    } else {
        status = PHPhotoLibrary.authorizationStatus()
    }
    switch status {
    case .authorized:
        completion(true)
    case .denied,.restricted:
        completion(false)
    case .notDetermined:
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                DispatchQueue.main.async {
                    completion(status == .authorized)
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization{ status in
                DispatchQueue.main.async {
                    completion(status == .authorized)
                }
            }
        }
    case .limited:completion(true)
    @unknown default:completion(false)
    }
}
//MARK: 获取相机权限
public func authorizeCameraStatus(completion: @escaping (Bool) -> Void){
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    switch status {
    case .authorized:
        completion(true)
    case .denied,.restricted:
        completion(false)
    case .notDetermined:
        AVCaptureDevice.requestAccess(for: .video) { state in
            DispatchQueue.main.async {
                completion(state)
            }
        }
    @unknown default:completion(false)
    }
}
//MARK: 跳转系统设置权限
public func systemSetting(){
    guard let setting = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(setting)
}

//读取本地图片
public func getBundleImage(name:String) -> UIImage? {
    let bundle = Bundle(for: ScanBaseVC.self)
    if let url = bundle.url(forResource: "scanResource", withExtension: "bundle"){
        
        let image = UIImage(named: name, in: Bundle(url: url), compatibleWith: nil)
        return image
    }
    return nil
}
