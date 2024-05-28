//
//  ScanCodeView.swift
//  ScanCodePackageDemo
//
//  Created by hqfy on 2024/1/19.
//

import UIKit
import AVFoundation

protocol ScanCodeViewDelegate: NSObjectProtocol {
    //扫码完成的回调
    func scanCodeDidFinished(result:ScanResult?)
}
class ScanCodeView: UIView {
    //扫码结束提示音文件路径
    public var soundFilePath:String?
    //是否播放扫码结束提示音, soundFilePath路径有值时有效
    public var isPlaySound:Bool = true
    //扫描实时亮度光线值 <-1
    public var brightnessChange:((Double) -> Void)?
    
    //闪光灯设置
    public var flashModel:AVCaptureDevice.TorchMode = .auto{
        didSet{
            guard let device = captureDevice, device.hasFlash else { return }
            
            guard device.isTorchModeSupported(.auto) else { return }
            
            do {
                try device.lockForConfiguration()
                device.torchMode = flashModel
                device.unlockForConfiguration()
                
            }catch{}
        }
    }
    
    
    public weak var scanDelegate:ScanCodeViewDelegate?
    
    public var scanAreaView:ScanAreaView = ScanAreaView()
    public var scanAnimation:ScanAnimation = ScanAnimation()
    
    public var scanStyle: ScanViewStyle = ScanViewStyle()
    
    public lazy var scanViewColor:UIColor = .blue
    
    public var metadata: MetaDataType = .allType
    
    private var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    
    private lazy var captureDevice:AVCaptureDevice? = {
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return nil}
        //白平衡
        if captureDevice.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
            try? captureDevice.lockForConfiguration()
            captureDevice.whiteBalanceMode = .continuousAutoWhiteBalance
            captureDevice.unlockForConfiguration()
        }
        
        //对焦
        if captureDevice.isFocusModeSupported(.continuousAutoFocus) {
            try? captureDevice.lockForConfiguration()
            captureDevice.focusMode = .continuousAutoFocus
            captureDevice.unlockForConfiguration()
        }
        
        //曝光度
        if captureDevice.isExposureModeSupported(.continuousAutoExposure) {
            try? captureDevice.lockForConfiguration()
            captureDevice.exposureMode = .continuousAutoExposure
            captureDevice.unlockForConfiguration()
        }
        
        return captureDevice
    }()
    
    private lazy var captureSession = AVCaptureSession()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        captureSession.sessionPreset = .high
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startScan() {

        authorizeCameraStatus{ auth in
            if !auth { //未认证去系统设置
                systemSetting()
                return
            }
        }
        //0.启动相机和视图
        createLayer()
        //1、打开扫描,直接打开会出现卡顿现象，放入视图将要出现时启动
        //startSession()
        //2、添加扫描视图
        drawScanView()
        //3、获取输入流
        sessionInput()
        //4、获取输出流
        sessionOutput()
    }
    
    //启动相机和视图
    private func createLayer() {

        backgroundColor = .black
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = layer.bounds
        guard let previewLayer = videoPreviewLayer else { return }
        layer.addSublayer(previewLayer)
    }

    //开启扫描
    public func startSession() {
        ScanAnimation.shared.startAnimation()
        let dispatchQueue = DispatchQueue(label: "scan_start_queue",qos: .userInteractive)
        dispatchQueue.async {
            self.captureSession.startRunning()
        }
    }
    //停止扫描
    public func stopSession() {
        ScanAnimation.shared.stopAnimation()
        let dispatchQueue = DispatchQueue(label: "scan_stop_queue",qos: .userInteractive)
        dispatchQueue.async {
            self.captureSession.stopRunning()
        }
    }
    
    func drawScanView(){
        scanAreaView = ScanAreaView(frame: frame, viewStyle: scanStyle)
        addSubview(scanAreaView)
        scanAreaView.startLoading(message: "加载中..")
        
        //添加双击缩放事件
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGuesture))
        tap.numberOfTapsRequired = 2
        scanAreaView.addGestureRecognizer(tap)
    }
    //双击事件
    @objc private func tapGuesture(){
        
        guard let device = captureDevice else { return }
        do{
            
            try device.lockForConfiguration()
            //[1, activeFormat.videoMaxZoomFactor]
            if device.videoZoomFactor == 1 {
                device.videoZoomFactor = 2
            }else{
                device.videoZoomFactor = 1
            }
            device.unlockForConfiguration()
        } catch{}
    }
    //输入流
    private func sessionInput() {
        guard let device = captureDevice else { return }
        
        do {
            let captureInput = try AVCaptureDeviceInput(device: device)
            captureSession.beginConfiguration()

            if let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput{
                captureSession.removeInput(currentInput)
            }
            
            captureSession.addInput(captureInput)
            captureSession.commitConfiguration()
        } catch  {
            
        }
        scanAreaView.stopLoading()
    }
    //输出流
    private func sessionOutput(){
        let videDataOutput  = AVCaptureVideoDataOutput()
        videDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        captureSession.addOutput(videDataOutput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        for type in metadata.value {
            if !metadataOutput.availableMetadataObjectTypes.contains(type){ return }
        }
        metadataOutput.metadataObjectTypes = metadata.value
        videoPreviewLayer?.session = captureSession
        setNeedsLayout()
    }
    
    //播放文件声音
    func playSound(){
        
        guard let soundPath = Bundle.main.path(forResource: soundFilePath, ofType: nil) else { return }
        guard let soundUrl = NSURL(string: soundPath) else { return }
        var soundID:SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundUrl, &soundID)
        AudioServicesPlaySystemSound(soundID)
    }
}

extension ScanCodeView: AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureMetadataOutputObjectsDelegate{
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
       let AttachmentDic = CMCopyDictionaryOfAttachments(allocator: nil, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
        
        guard let metadata = AttachmentDic as? [String: Any], let exifMetadata = metadata[kCGImagePropertyExifDictionary as String] as? [String: Any], let brightnessValue = exifMetadata[kCGImagePropertyExifBrightnessValue as String] as? Double else { return }
        //返回实时光线值  <-1
        if let bright = brightnessChange {
            bright(brightnessValue)
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if isPlaySound && soundFilePath != nil { playSound() }
        //暂停扫描
        stopSession()
        
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject else { return }
        if let del = scanDelegate {
            let result = ScanResult(content: object.stringValue,descriptor: object.descriptor,codeType: object.type.rawValue)
            del.scanCodeDidFinished(result: result)
        }
    }
}
