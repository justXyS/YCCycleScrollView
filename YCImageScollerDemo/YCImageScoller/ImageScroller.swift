//
//  ImageScroller.swift
//  YCImageScoller
//
//  Created by xiaoyuan on 2017/6/17.
//  Copyright © 2017年 YC. All rights reserved.
//

import UIKit
import Kingfisher

public final class CycleScrollView: UIView {
    
    public enum ViewType {
        case image(imageUrls: [String],placeholder: UIImage?)
        case customView(views: [UIView])
    }
    
    public lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.gray
        pageControl.pageIndicatorTintColor = UIColor.white
        pageControl.hidesForSinglePage = true
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    public var scrollLoop: Bool? {
        didSet {
            guard let scrollLoop = scrollLoop else {
                return
            }
            count = realCount * (scrollLoop ? 10 : 1)
            collectionView.reloadData()
            
            if scrollLoop {
                layoutIfNeeded()
                if scrollDirection == .vertical {
                    collectionView.contentOffset = CGPoint(x: 0, y: collectionView.bounds.height * CGFloat(count) / 2)
                } else {
                    collectionView.contentOffset = CGPoint(x: collectionView.bounds.width * CGFloat(count) / 2, y: 0)
                }
            } else {
                collectionView.contentOffset = CGPoint(x: 0, y: 0)
            }
            
        }
    }
    
    public typealias ScrollDirection = UICollectionViewScrollDirection
    
    public var customLayout: UICollectionViewLayout? {
        didSet {
            guard let customLayout = customLayout else {
                return
            }
            collectionView.setCollectionViewLayout(customLayout, animated: true)
            setupNormalContentOffset()
        }
    }
    
    public var scrollDirection: ScrollDirection = .horizontal {
        didSet {
            let layout = defaultLayout(by: scrollDirection)
            collectionView.setCollectionViewLayout(layout, animated: true)
            setupNormalContentOffset()
        }
    }
    
    public var type: ViewType? {
        didSet {
            guard let type = type else {
                return
            }
            switch type {
            case .image(let imageUrls, _):
                register(isImage: true)
                realCount = imageUrls.count
                scrollLoop =  scrollLoop ?? true
                pageControl.isHidden = false
                autoScroll =  autoScroll ?? true
            case .customView(let views):
                register(isImage: false)
                realCount = views.count
                scrollLoop =  scrollLoop ?? false
                pageControl.isHidden = true
                autoScroll = autoScroll ?? false
            }
            
            collectionView.reloadData()
            setupNormalContentOffset()
        }
    }
    
    public fileprivate(set) lazy var collectionView: UICollectionView = {
        let layout = self.defaultLayout(by: .horizontal)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    public var autoTime: TimeInterval = 4 {
        didSet {
            if autoScroll == true {
                autoTimer?.invalidate()
                autoTimer = nil
                autoTimer = Timer.scheduledTimer(timeInterval: autoTime, target: self, selector: #selector(autoScrollAction), userInfo: nil, repeats: true)
            }
        }
    }
    
    public var autoScroll: Bool? {
        didSet {
            if autoScroll == true {
                autoTimer = Timer.scheduledTimer(timeInterval: autoTime, target: self, selector: #selector(autoScrollAction), userInfo: nil, repeats: true)
            }
        }
    }
    
    fileprivate var count = 0
    fileprivate var realCount = 0 {
        didSet {
            pageControl.numberOfPages = realCount
            pageControl.currentPage = 0
            pageControl.sizeToFit()
            guard let scrollLoop = scrollLoop else {
                return
            }
            count = realCount * (scrollLoop ? 10 : 1)
            collectionView.reloadData()
            layoutIfNeeded()
        }
    }
    
    fileprivate var reuseIdentifer = ""
    
    fileprivate var autoTimer: Timer?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = self.bounds;
        collectionView.reloadData()
        pageControl.center = CGPoint(x: self.collectionView.frame.width / 2, y: self.collectionView.frame.height - 10 - pageControl.bounds.height / 2)
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview == nil {
            autoTimer?.invalidate()
            autoTimer = nil
        }
    }
    
    private func register(isImage: Bool) {
        if isImage {
            reuseIdentifer = "imageCell"
            collectionView.register(ImageCell.classForCoder(), forCellWithReuseIdentifier: reuseIdentifer)
        } else {
            reuseIdentifer = "UICollectionViewCell"
            collectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: reuseIdentifer)
        }
    }
    
    private func setup() {
        addSubview(collectionView)
        addSubview(pageControl)
    }
    
    private func defaultLayout(by direction: ScrollDirection) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = direction
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        return layout
    }
    
    private func setupNormalContentOffset() {
        if count > 0 {
            guard let scrollLoop = scrollLoop else {
                return
            }
            
            if scrollLoop {
                layoutIfNeeded()
                if scrollDirection == .vertical {
                    collectionView.contentOffset = CGPoint(x: 0, y: collectionView.bounds.height * CGFloat(count) / 2)
                } else {
                    collectionView.contentOffset = CGPoint(x: collectionView.bounds.width * CGFloat(count) / 2, y: 0)
                }
            } else {
                collectionView.contentOffset = CGPoint(x: 0, y: 0)
            }
        }
    }
    
    @objc private func autoScrollAction() {
        
        let currentPage: Int
        if scrollDirection == .horizontal {
            currentPage = Int(collectionView.contentOffset.x / collectionView.bounds.width) + 1
        } else {
            currentPage = Int(collectionView.contentOffset.y / collectionView.bounds.height) + 1
        }
        let realPage = currentPage % realCount
        
        if (scrollLoop == nil || !scrollLoop!) && (realPage >= realCount) {
            return
        }
        
        pageControl.currentPage = realPage
        
        if scrollDirection == .vertical {
            collectionView.setContentOffset(CGPoint(x: 0, y: collectionView.bounds.height * CGFloat(currentPage)), animated: true)
        } else {
            collectionView.setContentOffset(CGPoint(x: collectionView.bounds.width * CGFloat(currentPage), y: 0), animated: true)
        }
    }

}

extension CycleScrollView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width, height: self.frame.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        
        switch type! {
        case .image(let imageUrls, let placeholder):
            let url = imageUrls[indexPath.item % imageUrls.count]
            let icell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifer, for: indexPath) as! ImageCell
            icell.update(url: url, placeholder: placeholder)
            cell = icell
        case .customView(let views):
            let view = views[indexPath.item % views.count]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifer, for: indexPath)
            _ = cell.contentView.subviews.map({
                $0.removeFromSuperview()
            })
            view.frame = cell.contentView.bounds
            cell.contentView.addSubview(view)
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage: Int
        if scrollDirection == .horizontal {
            currentPage = Int(scrollView.contentOffset.x / collectionView.bounds.width)
            
        } else {
            currentPage = Int(scrollView.contentOffset.y / collectionView.bounds.height)
        }
        let realPage = currentPage % realCount
        pageControl.currentPage = realPage
        
        guard let scrollLoop = scrollLoop, scrollLoop else {
            return
        }
        if currentPage > count/2 + realCount || currentPage < count/2 - realCount {
            if scrollDirection == .horizontal {
                scrollView.setContentOffset(CGPoint(x: collectionView.frame.width * CGFloat(realPage + count / 2), y: 0), animated: false)
            } else {
            scrollView.setContentOffset(CGPoint(x: 0, y: collectionView.frame.height * CGFloat(realPage + count / 2)), animated: false)
            }
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let currentPage: Int
        if scrollDirection == .horizontal {
            currentPage = Int(scrollView.contentOffset.x / collectionView.bounds.width)
            
        } else {
            currentPage = Int(scrollView.contentOffset.y / collectionView.bounds.height)
        }
        let realPage = currentPage % realCount
        pageControl.currentPage = realPage
        
        guard let scrollLoop = scrollLoop, scrollLoop else {
            return
        }
        if currentPage > count/2 + realCount || currentPage < count/2 - realCount {
            if scrollDirection == .horizontal {
                scrollView.setContentOffset(CGPoint(x: collectionView.frame.width * CGFloat(realPage + count / 2), y: 0), animated: false)
            } else {
                scrollView.setContentOffset(CGPoint(x: 0, y: collectionView.frame.height * CGFloat(realPage + count / 2)), animated: false)
            }
        }
    }
    
}

class ImageCell: UICollectionViewCell {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.kf.indicatorType = .activity
        return imageView
    }()
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds
    }
    
    func update(url: String, placeholder: UIImage?) {
        let u = URL(string: url)!
        if u.scheme == "http" || u.scheme == "https" {
            imageView.kf.setImage(with: u, placeholder: placeholder)
        } else {
            let image = UIImage(contentsOfFile: url)
            imageView.image = image ?? UIImage(named: url)
        }
    }
    
}

