//
//  NaruBottomSheetTagFilterViewController.swift
//  NaruiUIComponents
//
//  Created by Changyeol Seo on 2020/11/27.
//

import UIKit
import UBottomSheet
import TagListView

fileprivate var preSelectedTags:[String:[String]]? = nil

public extension Notification.Name {
    static let naruBottomSheetTagFilterSelectionDidChange = Notification.Name("naruBottomSheetTagFilterSelectionDidChange_observer")
}

public class NaruBottomSheetTagFilterViewController: UIViewController, Draggable {
    deinit {
        print("NaruBottomSheetTagFilterViewController deinit!!")
    }

    struct Model {
        struct Tag {
            let text:String
            let prefix:String?
            var displayText:String {
                return "\(prefix ?? "")\(text)"
            }
        }
        struct FilterSet {
            let title:String
            let tags:[Tag]
        }
    }
    
    var filterSets:[Model.FilterSet] = [
        Model.FilterSet(
            title: "상태", tags: [
                Model.Tag(text: "숙면", prefix: "#"),
                Model.Tag(text: "스트레스해소", prefix: "#"),
                Model.Tag(text: "체력증진", prefix: "#"),
                Model.Tag(text: "우울해소", prefix: "#"),
                Model.Tag(text: "불안해소", prefix: "#"),
            ]),
        Model.FilterSet(
            title: "클래스", tags: [
                Model.Tag(text: "홈트레이닝", prefix: nil),
                Model.Tag(text: "스트레스해소", prefix: nil),
                Model.Tag(text: "댄스카디오", prefix: nil),
                Model.Tag(text: "요가&명상", prefix: nil),
                Model.Tag(text: "북테라피", prefix: nil),
                Model.Tag(text: "사운드테라피", prefix: nil),
            ])
    ]
    
    public static var viewController : NaruBottomSheetTagFilterViewController {
        let storyboard = UIStoryboard(name: "NaruBottomSheets", bundle: Bundle(for: NaruBottomSheetTagFilterViewController.self))
        if #available(iOS 13.0, *) {
            return storyboard.instantiateViewController(identifier: "tagFilter")
        } else {
            return storyboard.instantiateViewController(withIdentifier: "tagFilter") as! NaruBottomSheetTagFilterViewController
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var applyButton: UIButton!
    
    
    public var sheetCoordinator: UBottomSheetCoordinator?
//    let dataSorce = PullToDismissDataSource()

    weak var dimViewController:UIViewController? = nil
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInsetAdjustmentBehavior = .never
        // Do any additional setup after loading the view.
        if let tags = preSelectedTags {
            print(tags)
        }
        applyButton.setBackgroundImage(UIColor(white: 0, alpha: 0.5).image, for: .highlighted)
    }
        
    public func showBottomSheet(targetViewController vc:UIViewController, selectedTags:[String:[String]]? = nil){
        preSelectedTags = selectedTags
        let dimvc = UIViewController()
        dimViewController = dimvc
        dimViewController?.view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        dimViewController?.modalTransitionStyle = .crossDissolve
        dimViewController?.modalPresentationStyle = .overFullScreen
        
        sheetCoordinator = UBottomSheetCoordinator(parent: vc)
//        sheetCoordinator?.dataSource = dataSorce
        sheetCoordinator?.addSheet(self, to: dimvc, didContainerCreate: { container in
            let f = self.view.frame
            let rect = CGRect(x: f.minX, y: f.minY, width: f.width, height: f.height)
            
            container.roundCorners(corners: [.topLeft, .topRight], radius: 16, rect: rect)
        })
        vc.present(dimvc, animated: true, completion: nil)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //adds pan gesture recognizer to draggableView()
        sheetCoordinator?.startTracking(item: self)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dimViewController?.dismiss(animated: true, completion: nil)
    }
   
    
    public func draggableView() -> UIScrollView? {
        return tableView
    }
    
    @IBAction func onTouchUpApplyButton(_ sender: Any) {
        sheetCoordinator?.removeSheetChild(item: self)
    }
}

extension NaruBottomSheetTagFilterViewController : UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterSets.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filterSet = filterSets[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NaruBottomSheetTagFilterTableViewCell
        cell.data = filterSet
        return cell
    }
}


class NaruBottomSheetTagFilterTableViewCell : UITableViewCell {
    var data:NaruBottomSheetTagFilterViewController.Model.FilterSet? = nil {
        didSet {
            updateUI()
        }
    }
    
    var selectedTags:[String] {
        var result:[String] = []
        for view in tagListView.selectedTags() {
            if let title = view.currentTitle {
                if let prefix = data?.tags.first?.prefix {
                    let new = title[prefix.count..<title.count]
                    result.append(new)
                } else {
                    result.append(title)
                }
            }
        }
        return result
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var tagListViewHeight: NSLayoutConstraint!
    override func didMoveToWindow() {
        super.didMoveToWindow()
        tagListView.autoresizingMask = [.flexibleHeight]
        fixlayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fixlayout()
    }
    
    func fixlayout() {
        tagListView.textFont = UIFont.systemFont(ofSize: 12)
        let newHeight = tagListView.intrinsicContentSize.height
        tagListViewHeight.constant = newHeight + tagListView.paddingY + tagListView.marginY + 12
    }
    
    func updateUI() {
        let title = data?.title ?? ""
        titleLabel.text = title
        tagListView.removeAllTags()

        for tag in data?.tags ?? [] {
            let tagView = tagListView.addTag(tag.displayText)
            let stags = preSelectedTags?[title] ?? []
            let isSelected = stags.filter { (str) -> Bool in
                return str == tag.text
            }.count > 0
            tagView.isSelected = isSelected
    
            tagView.onTap = { [weak self] tagView in
                tagView.isSelected.toggle()
                self?.notiResult()
            }
            tagView.onLongPress = { _ in
            }
        }
        fixlayout()
    }
    
    func notiResult() {
        NotificationCenter.default.post(
            name: .naruBottomSheetTagFilterSelectionDidChange,
            object: selectedTags,
            userInfo: ["title" : data?.title ?? ""] )
    }
    
}

class PullToDismissDataSource: UBottomSheetCoordinatorDataSource {
    func sheetPositions(_ availableHeight: CGFloat) -> [CGFloat] {
        return [0.7, 1.1].map{$0*availableHeight} /// Trick is to set bottom position to any value more than available height such as 1.1*availableHeight
    }
    
    func initialPosition(_ availableHeight: CGFloat) -> CGFloat {
        return availableHeight*0.7
    }
}

