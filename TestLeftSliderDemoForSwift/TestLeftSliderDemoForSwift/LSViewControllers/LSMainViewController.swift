//
//  LSMainViewController.swift
//  TestLeftSliderDemoForSwift
//
//  Created by 邓伟浩 on 2020/6/1.
//  Copyright © 2020 邓伟浩. All rights reserved.
//

import UIKit

class LSMainViewController: LSBaseVC {
    
    var leftVC: LSLeftMenuViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        let board = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        leftVC = board.instantiateViewController(withIdentifier: "LeftMenuVC") as? LSLeftMenuViewController
        leftVC.manager = WHLeftSlideManager.shared
        WHLeftSlideManager.shared.set(leftViewController: leftVC, mainViewController: self)
    }

    @IBAction func showLeftMenuView(_ sender: Any) {
        WHLeftSlideManager.shared.show()
    }
    
    @IBAction func exchange(_ sender: Any) {
        let board = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let anotherVC = board.instantiateViewController(withIdentifier: "AnotherVC")
        (UIApplication.shared.delegate as? LSAppDelegate)?.window?.rootViewController = anotherVC
    }
}

class LSLeftMenuViewController: LSBaseVC {
    var manager: WHLeftSlideManager?
    
    @IBAction func pushToSecondVC(_ sender: Any) {
        let board = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let secondVC = board.instantiateViewController(withIdentifier: "SecondVC")
        manager?.dismiss()
        manager?.mainVC.navigationController?.pushViewController(secondVC, animated: true)
    }
}

class LSAnotherViewController: LSBaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func exchange(_ sender: Any) {
        let board = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let rootVC = board.instantiateViewController(withIdentifier: "rootVC")
        (UIApplication.shared.delegate as? LSAppDelegate)?.window?.rootViewController = rootVC
    }
    
}

class LSBaseVC: UIViewController {
    deinit {
        NSLog("=====释放\(self)=====")
    }
}
