//
//  MindColorTestViewController.swift
//  NaruiUIComponents_Example
//
//  Created by Changyeol Seo on 2020/11/24.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import NaruiUIComponents

class MindColorTestViewController : UIViewController {
    
    @IBOutlet weak var tagCollectionView: NaruTagCollectionView!
    @IBOutlet var ringProgressView: [NaruRingProgressView]!
    let ringDatas:[NaruRingProgressView.ViewModel] = [
        NaruRingProgressView.ViewModel(secondLabelText: "감자", progress: 0.1, forgroundColor: .yellow, ringBackgrouncColor: UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.1)),
        NaruRingProgressView.ViewModel(secondLabelText: "고구마", progress: 0.2, forgroundColor: .orange, ringBackgrouncColor: UIColor(red: 1.0, green: 0.0, blue: 0.5, alpha: 0.1))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for (index,rview) in ringProgressView.enumerated() {
            rview.viewModel = ringDatas[index]
        }
        tagCollectionView.tags = ["바보","강아지","고양이","태권브이","고구마","감자"]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "tag", style: .plain, target: self, action: #selector(self.onTouchUPRightBarButton(_:)))
        
        NotificationCenter.default.addObserver(forName: .naruBottomSheetTagFilterSelectionDidChange, object: nil, queue: nil) {[weak self] (noti) in
        
            if let tags = noti.object as? [String],
               let title = noti.userInfo?["title"] as? String {
                print("tags: \(tags) title : \(title)")
                if title == "상태" {
                    self?.tagCollectionView.tags = tags
                }
            }
        }
    }
    
    @objc func onTouchUPRightBarButton(_ sender:UIBarButtonItem) {
        NaruBottomSheetTagFilterViewController.viewController.showBottomSheet(targetViewController: self , selectedTags: ["상태":tagCollectionView.tags])
    }
}
