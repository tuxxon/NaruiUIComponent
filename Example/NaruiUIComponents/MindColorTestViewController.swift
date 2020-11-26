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
        
    }
}
