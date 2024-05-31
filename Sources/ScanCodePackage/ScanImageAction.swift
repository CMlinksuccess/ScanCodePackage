//
//  ScanAction.swift
//  ScanCodePackageDemo
//
//  Created by hqfy on 2024/1/25.
//

import UIKit
import AVFoundation
import Photos
import Vision

protocol ScanImageActionDelegate:NSObjectProtocol {
    //识码结果回调
    func scanImageDidFinished(result:ScanResult?)
}

class ScanImageAction: NSObject{
    
    public weak var delegate: ScanImageActionDelegate?
    private let pickControl = UIImagePickerController()
    
    //选择相册图片并识别二维码
    public func selectPickImage(vc:UIViewController) {
        authorizePhotoStatus { auth in
            if !auth { //未认证去系统设置
                systemSetting()
                return
            }
            self.pickControl.delegate = self
            //pickControl.allowsEditing = true
            self.pickControl.sourceType = .photoLibrary
            vc.present(self.pickControl, animated: true)
        }
    }
    //识别图片中的二维码,条形码无法识别
    public func scanQRCodeImage(qrImage:UIImage) -> [ScanQRResult]{
        guard let cgImage = qrImage.cgImage else { return []}
        let detector = CIDetector(ofType:CIDetectorTypeQRCode, context: nil,options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
        let img = CIImage(cgImage: cgImage)
        let features = detector.features(in: img, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        return features.filter{
            $0.isKind(of: CIQRCodeFeature.self)
        }.map{
            $0 as! CIQRCodeFeature
        }.map {
            ScanQRResult(content: $0.messageString, img: qrImage, codeType: AVMetadataObject.ObjectType.qr.rawValue)
        }
    }
    //识别图片中的二维码/条形码
    public func parseBarCode(img:UIImage, complete:@escaping ((String?,CIBarcodeDescriptor?,String?)->Void)) {
        guard let cgimg = img.cgImage else { return complete(nil,nil,nil)}
        
        let request = VNDetectBarcodesRequest { request, error in
            if error != nil { return complete(nil,nil,nil) }
            guard let results = request.results, results.count > 0 else { return complete(nil,nil,nil)}
            for result in results {
                
                if let barcode = result as? VNBarcodeObservation, let value = barcode.payloadStringValue {

                    complete(value,barcode.barcodeDescriptor,barcode.symbology.rawValue)
                }
            }
        }
        let handler = VNImageRequestHandler(cgImage: cgimg)
        do{
            try handler.perform([request])
        }catch{
            complete(nil,nil,nil)
            print(error)
        }
    }
}

extension ScanImageAction:UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    //选中相册图片回调
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        let editedImage = info[.editedImage] as? UIImage
        let originalImage = info[.originalImage] as? UIImage
        guard let image = editedImage ?? originalImage else { return }

        //子线程识别图片
        DispatchQueue.global(qos: .userInitiated).async {
            self.parseBarCode(img: image) { val, info, symbology in
                //返回主线程
                DispatchQueue.main.async {
                    if let del = self.delegate {
                        let result = ScanResult(content: val,descriptor: info,codeType: symbology)
                        del.scanImageDidFinished(result: result)
                    }
                }
            }
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

//MARK: - 生成二维码图片异步调用
public func generateQRCodeImage(content:String, size:CGSize = CGSize(width: 50, height: 50),codeType:String = "CIQRCodeGenerator",codeColor:UIColor = .black, bgColor:UIColor = .white, complete:@escaping((UIImage?)->Void)){
        DispatchQueue.global(qos: .userInitiated).async {
            let contentData = content.data(using: .utf8)
            /***
             CIQRCodeGenerator      二维码
             CIAztecCodeGenerator  二维码,暂不支持
                .....
             */
            guard let qrFilter = CIFilter(name: codeType) else {
                complete(nil)
                return
            }
            qrFilter.setDefaults()
            qrFilter.setValue(contentData, forKey: "inputMessage")
            // 设置容错率，可选值：L(7%), M(15%), Q(25%), H(30%)
            qrFilter.setValue("H", forKey: "inputCorrectionLevel")
            
            guard let qrImage = qrFilter.outputImage else {
                complete(nil)
                return
            }
            //修改颜色
            let colorFilter = CIFilter(name: "CIFalseColor",
                                       parameters:
                                        [
                                            "inputImage":qrImage,
                                            "inputColor0":CIColor(color: codeColor),
                                            "inputColor1":CIColor(color: bgColor)
                                        ])
            
            guard let outputImage = colorFilter?.outputImage, let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent) else {
                complete(nil)
                return
            }
            UIGraphicsBeginImageContext(size)
            let context = UIGraphicsGetCurrentContext()!
            context.interpolationQuality = CGInterpolationQuality.none
            context.scaleBy(x: 1.0, y: -1.0)
            context.draw(cgImage, in: context.boundingBoxOfClipPath)
            let codeImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            DispatchQueue.main.async {
                complete(codeImage)
            }
        }
    }
//MARK: - 生成二维码图片同步调用
public func generateQRCodeImage(content:String, size:CGSize = CGSize(width: 50, height: 50),codeType:String = "CIQRCodeGenerator",codeColor:UIColor = .black, bgColor:UIColor = .white) -> UIImage?{
    
    let contentData = content.data(using: .utf8)
    /***
     CIQRCodeGenerator      二维码
     CIAztecCodeGenerator  二维码,暂不支持
        .....
     */
    guard let qrFilter = CIFilter(name: codeType) else { return nil }
    qrFilter.setDefaults()
    qrFilter.setValue(contentData, forKey: "inputMessage")
    qrFilter.setValue("H", forKey: "inputCorrectionLevel")
    
    guard let qrImage = qrFilter.outputImage else { return nil }
    //修改颜色
    let colorFilter = CIFilter(name: "CIFalseColor",
                               parameters:
                                [
                                    "inputImage":qrImage,
                                    "inputColor0":CIColor(color: codeColor),
                                    "inputColor1":CIColor(color: bgColor)
                                ])
    
    guard let outputImage = colorFilter?.outputImage, let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent) else {
        return nil
    }
    UIGraphicsBeginImageContext(size)
    let context = UIGraphicsGetCurrentContext()!
    context.interpolationQuality = CGInterpolationQuality.none
    context.scaleBy(x: 1.0, y: -1.0)
    context.draw(cgImage, in: context.boundingBoxOfClipPath)
    let codeImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return codeImage
}
//MARK: - 生成条形码图片异步调用
    public func generateBarCodeImage(content:String, codeType:String = "CICode128BarcodeGenerator",complete:@escaping((UIImage?)->Void)){
        DispatchQueue.global(qos: .userInitiated).async {
            let contentData = content.data(using: .utf8)
            /***
             CICode128BarcodeGenerator 条形码
             CIPDF417BarcodeGenerator  条形码
                .....
             */
            guard let qrFilter = CIFilter(name: codeType) else {
                complete(nil)
                return
            }
            qrFilter.setDefaults()
            qrFilter.setValue(contentData, forKey: "inputMessage")
            
            guard let outputImage = qrFilter.outputImage, let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent) else {
                complete(nil)
                return
            }
            
            let image = UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)
            let resizeImage = resizeImage(image: image, quality: .none, rate: 20)
            
            DispatchQueue.main.async {
                complete(resizeImage)
            }
        }
    }
//MARK: - 生成条形码图片同步调用
    public func generateBarCodeImage(content:String, codeType:String = "CICode128BarcodeGenerator") -> UIImage?{
        
        let contentData = content.data(using: .utf8)
        /***
         CICode128BarcodeGenerator 条形码
         CIPDF417BarcodeGenerator  条形码
            .....
         */
        guard let qrFilter = CIFilter(name: codeType) else { return nil }
        qrFilter.setDefaults()
        qrFilter.setValue(contentData, forKey: "inputMessage")
        
        guard let outputImage = qrFilter.outputImage, let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        let image = UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)
        let resizeImage = resizeImage(image: image, quality: .none, rate: 20)
        return resizeImage
    }
//MARK: - 图片缩放
    public func resizeImage(image:UIImage, quality:CGInterpolationQuality, rate: CGFloat) -> UIImage? {
        var resized:UIImage?
        let width = image.size.width * rate
        let height = image.size.height * rate
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        let context = UIGraphicsGetCurrentContext()
        context?.interpolationQuality = quality
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resized
    }


