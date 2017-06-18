# YCCycleScrollView
即可用于图片轮播，又可用于需要支持手势切换的控制器和view，支持设置滚动方向

#pod

```
pod YCCycleScrollView
```

# 使用示例
***

```
let v2 = UIViewController()
v2.view.backgroundColor = UIColor.red
        
let v3 = UIViewController()
v3.view.backgroundColor = UIColor.blue
        
let v1 = UIViewController()
v1.view.backgroundColor = UIColor.yellow
        
scroller.type = .customView(views:[v1.view,v2.view,v3.view])
```
```
imageScroller.type = .image(imageUrls: [
										"http://img1.3lian.com/img013/v3/2/d/61.jpg",
										"http://pic27.nipic.com/20130310/10753400_162542616102_2.jpg",
										"http://pic.35pic.com/normal/07/64/08/10753400_161620411143_2.jpg"],
						  placeholder: nil)
```