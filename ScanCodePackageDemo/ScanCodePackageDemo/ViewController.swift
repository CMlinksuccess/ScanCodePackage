//
//  ViewController.swift
//  ScanCodePackageDemo
//
//  Created by hqfy on 2024/1/19.
//

import UIKit

class ViewController: UIViewController {
    
    let tableView = UITableView()
    
    let cellID = "tableViewCell"
    let list = ["默认样式","全屏样式","继承修改自定义","完全自定义样式","生成二维码/条形码"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.frame = view.bounds
        tableView.rowHeight = 60
        let headLab = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        headLab.text = "不同样式扫一扫"
        headLab.textColor = .blue
        headLab.font = .systemFont(ofSize: 20)
        headLab.textAlignment = .center
        tableView.tableHeaderView = headLab
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    
        view.addSubview(tableView)
    }
}


extension ViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        if #available(iOS 14.0, *) {
            
            var config = UIListContentConfiguration.cell()
            config.text = list[indexPath.row]
            config.textProperties.color = .black
            cell.contentConfiguration = config
        
        } else {
            cell.textLabel?.text = list[indexPath.row]
        }
     
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        switch indexPath.row {
        case 0://默认样式
            let scanvc = ScanBaseVC()
            scanvc.modalPresentationStyle = .fullScreen
            scanvc.setGenerateCodeConfig(content: "这是生成二维码的内容",size: CGSize(width: 100, height: 100))
            scanvc.delegate = self
            self.present(scanvc, animated: true)
        case 1://全屏样式
            let scanvc = ScanBaseVC()
            scanvc.modalPresentationStyle = .fullScreen
            scanvc.style.scanAreaStyle = .screen
            scanvc.setGenerateCodeConfig(content: "这是生成二维码的内容",size: CGSize(width: 100, height: 100))
            scanvc.delegate = self
            //scanvc.getCodeBtn.isHidden = true //可隐藏按钮
            self.present(scanvc, animated: true)
        case 2://继承修改自定义样式
            let scanvc = InheritScanVC()
            scanvc.modalPresentationStyle = .fullScreen
            self.present(scanvc, animated: true)
        case 3://完全自定义样式
            let scanvc = CustomizedScanVC()
            scanvc.modalPresentationStyle = .fullScreen
            self.present(scanvc, animated: true)
        case 4://生成二维码/条形码
            let scanvc = GenerateCodeVC()
            scanvc.modalPresentationStyle = .fullScreen
            self.present(scanvc, animated: true)
        default:break
        }
    }
}


extension ViewController: ScanBaseVCDelegate {
    func scanCodeBaseDidFinished(result: String?, codeType: String) {
        print("扫码完成的结果内容\(String(describing: result))")
    }
    
    func scanImageBaseDidFinished(result: ScanResult?) {
        print("识别图片完成的结果内容\(String(describing: result))")
    }

    func scanGenerateCodeImage(image: UIImage?) {
        print("生成的二维码图片\(String(describing: image))")
    }
}
