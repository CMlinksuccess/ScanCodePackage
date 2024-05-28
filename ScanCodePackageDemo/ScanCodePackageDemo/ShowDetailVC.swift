//
//  ShowImageVC.swift
//  ScanCodePackageDemo
//
//  Created by hqfy on 2024/5/28.
//

import UIKit

class ShowDetailVC: UIViewController {

    public var result: ScanResult?
    
    let detailLab = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        backBtn()
        
        
        detailLab.frame = view.bounds
        view.addSubview(detailLab)
        detailLab.font = .systemFont(ofSize: 20)
        detailLab.numberOfLines = 0
        detailLab.text = "  内容：\(result?.content ?? "空")\n\n  码类型：\(result?.codeType ?? "无")\n\n  码详情：\(String(describing: result?.descriptor))"
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
}
