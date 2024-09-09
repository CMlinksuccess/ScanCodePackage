//
//  ScanAnimation.swift
//  ScanCodePackageDemo
//
//  Created by hqfy on 2024/1/22.
//

import UIKit


public class ScanAnimation: NSObject {
    
    static let shared:ScanAnimation = {
        
        let instance = ScanAnimation()
        
        return instance
    }()
    
    private lazy var animationImageView = UIImageView()
    
    private var displayLink: CADisplayLink?
    
    private var tempFrame: CGRect?
    
    private var contentHeight: CGFloat?
    
    private var animationStyle: ScanAnimationStyle = .lineMove
    
    //通用参数
    public func scanAnimation(_ rect:CGRect, _ parentView:UIView, imageView:UIImageView?, style: ScanAnimationStyle){
        guard let imgView = imageView else { return }
        animationStyle = style
        
        switch style {
        
        case .grid,.lineMove:
            tempFrame = imgView.frame
            animationImageView = imgView
            contentHeight = rect.minY + rect.height
            parentView.addSubview(imgView)
            
            setupDisplayLink()
            //开始扫描动画
            startAnimation()
            
        case .lineStill:
            animationImageView = imgView

            animationImageView.center = CGPoint(x: rect.minX + rect.width / 2.0, y: rect.minY + rect.height / 2.0)
            
            parentView.addSubview(imgView)
            
        default:
            break
        }
    }
    
    private func setupDisplayLink() {
        if displayLink != nil { return }
        displayLink = CADisplayLink(target: self, selector: #selector(animation))
        
        displayLink?.add(to: .current, forMode: .common)
        
        displayLink?.isPaused = true
    }
    
    @objc private func animation(){
        if animationImageView.frame.maxY > contentHeight! {
            animationImageView.frame = tempFrame ?? .zero
        }
        //心率距离
        var rate:CGFloat = 2
        if animationStyle == .grid {
            rate = 1
            var temFrame = animationImageView.frame
            temFrame.size.height = temFrame.size.height + rate
            animationImageView.frame = temFrame
        }
        
        animationImageView.transform = CGAffineTransform(translationX: 0, y: rate).concatenating(animationImageView.transform)
    }
    
    public func startAnimation() {
        if displayLink == nil {
            setupDisplayLink()
        }
        displayLink?.isPaused = false
    }
    
    public func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }
}
