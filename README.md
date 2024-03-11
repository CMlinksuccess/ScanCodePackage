# ScanCodePackage
扫码、扫描二维码/条形码功能，自定义扫码界面视图，生成二维码/条形码

<img src="https://github.com/CMlinksuccess/ScanCodePackage/blob/main/image/scanImage1.jpeg"  width="150" height="324" alt="效果图1"> <img src="https://github.com/CMlinksuccess/ScanCodePackage/blob/main/image/scanImage2.jpeg" width="150" height="324" alt="效果图2"> <img src="https://github.com/CMlinksuccess/ScanCodePackage/blob/main/image/scanImage3.jpeg" width="150" height="324" alt="效果图3"> <img src="https://github.com/CMlinksuccess/ScanCodePackage/blob/main/image/scanImage4.jpeg" width="150" height="324" alt="效果图4"> <img src="https://github.com/CMlinksuccess/ScanCodePackage/blob/main/image/scanImage5.jpeg" width="150" height="324" alt="效果图5"> <img src="https://github.com/CMlinksuccess/ScanCodePackage/blob/main/image/scanImage6.jpeg" width="150" height="324" alt="效果图6"> <img src="https://github.com/CMlinksuccess/ScanCodePackage/blob/main/image/scanImage7.jpeg" width="150" height="324" alt="效果图7">

环境适配
```
swift 5.0+
ios 11.0+
```

## Swift Package Manager
请将以下添加到Package.swift的依赖项值中：
```
dependencies: [
    .package(url: "https://github.com/CMlinksuccess/ScanCodePackage.git", from: "1.0.0")
]
```

## CocoaPods使用
 在Podfile文件中添加：
```
pod 'ScanCodePackage' ,:git =>"git@github.com:CMlinksuccess/ScanCodePackage.git"
```
然后，执行下面命令：
```
$ pod install
```
## 使用功能
1. 调用扫码功能（扫描二维码/条形码、图片识别二维码/条形码、生成二维码/条形码）
2. 自定义扫码界面UI（继承式自定义修改样式，完全自定义调用封装组件）
3. 生成二维码/条形码

## 使用方法

1、调用扫描页面，监听ScanBaseVCDelegate 实现结果回调
```swift
let scanvc = ScanBaseVC()
scanvc.delegate = self
self.present(scanvc, animated: true)
```

2、扫码样式类型
```swift

//MARK: 扫码区域类型
enum ScanAreaStyle {
    case screen //全屏，或传入视图100%扫描
    case angle  //矩形框区域
}

//MARK: 扫码区域动画类型
enum ScanAnimationStyle {
    case lineMove  //线条上下移动
    case grid      //网格扫描
    case lineStill //线条停放在中间位置
    case none      //无动画效果
}
//MARK: 扫码区域四角位置类型
enum ScanFrameAngleStyle {
    case inner //内嵌，一般无矩形框显示效果
    case outer //矩形框角上外嵌
    case on    //矩形框角上覆盖
}
```
扫码视图参数配置
```swift
//扫码视图参数配置
struct ScanViewStyle {
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
```
结果回调
```swift
extension CustomizedScanVC:ScanCodeViewDelegate, ScanImageActionDelegate{
    func scanCodeDidFinished(result: String?, codeType: String) {
        print("扫码结果回调")
    }
    
    func scanImageDidFinished(result: ScanResult?) {
        print("图片码识别结果回调")
    }
}
```
3、生成二维码/条形码
```swift
//生成二维码
 let image =  generateQRCodeImage(content: "生成二维码的内容8993847349",size: CGSize(width: 200, height: 200), codeType: "CIQRCodeGenerator",codeColor: .green,bgColor: .white)
//生成条形码
 let image =  generateBarCodeImage(content: "7928347957wjer",codeType: "CICode128BarcodeGenerator")
//缩放图片大小
 if let img = image {
    let resizeImage = resizeImage(image: img, quality: .none, rate: 2)
 } 
```

# 内部资源
scanResource.bundle
