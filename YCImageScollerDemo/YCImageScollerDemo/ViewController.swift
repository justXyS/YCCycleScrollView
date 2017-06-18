//
//  ViewController.swift
//  YCImageScollerDemo
//
//  Created by xiaoyuan on 2017/6/18.
//  Copyright © 2017年 YC. All rights reserved.
//

import UIKit
import YCImageScoller

class ViewController: UIViewController {

    @IBOutlet weak var imageScroller: CycleScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let v2 = UIViewController()
        v2.view.backgroundColor = UIColor.red
        
        let v3 = UIViewController()
        v3.view.backgroundColor = UIColor.blue
        
        let v1 = UIViewController()
        v1.view.backgroundColor = UIColor.yellow
        
        imageScroller.type = CycleScrollView.ViewType.customView(views: [v1.view,v2.view,v3.view])
//        (imageUrls: ["http://img1.3lian.com/img013/v3/2/d/61.jpg","http://pic27.nipic.com/20130310/10753400_162542616102_2.jpg","http://pic.35pic.com/normal/07/64/08/10753400_161620411143_2.jpg"],placeholder: nil)
        imageScroller.scrollLoop = false
//        imageScroller.scrollDirection = .vertical
        
    }


}

