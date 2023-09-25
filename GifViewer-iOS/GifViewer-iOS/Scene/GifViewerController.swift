//
//  GifViewerController.swift
//  GifViewer
//
//  Created by Chang-Hoon Han on 2020/08/03.
//  Copyright © 2020 Chang-Hoon Han. All rights reserved.
//

import UIKit
import FSPagerView
import Nuke
//import NukeWebPPlugin
//import KingfisherWebP
import SwiftyGif
import SDWebImage
import Gifu
import JellyGif
import Kingfisher

class GifViewerController: UIViewController {
    
    private var mediaPlayer: AVMediaPlayer?
    @IBOutlet weak var videoView: VideoView!
    @IBOutlet weak var pagerView: FSPagerView!

    var animationImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        /**
         * 미디어 재생
         */
        //let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!
        let filePath = Bundle.main.path(forResource: "4", ofType: "mp4")!
        let url = URL(fileURLWithPath: filePath)
        mediaPlayer = AVMediaPlayer(url: url, view: videoView, videoGravity: .resizeAspectFill) {
            /*
            if let player = self.mediaPlayer {
                player.seekTo(seconds: 60)
            }*/
        }
        
        /**
         * FSPagerView 라이브러리
         * https://github.com/WenchaoD/FSPagerView
         */
        self.pagerView.dataSource = self
        self.pagerView.delegate = self
        self.pagerView.register(UINib(nibName: String(describing: GifViewerCell.self), bundle: nil), forCellWithReuseIdentifier: "GifViewerCell1")
        self.pagerView.register(UINib(nibName: String(describing: GifViewerCell.self), bundle: nil), forCellWithReuseIdentifier: "GifViewerCell2")
        self.pagerView.register(UINib(nibName: String(describing: GifViewerCell.self), bundle: nil), forCellWithReuseIdentifier: "GifViewerCell3")
        self.pagerView.register(UINib(nibName: String(describing: GifViewerCell.self), bundle: nil), forCellWithReuseIdentifier: "GifViewerCell4")
        self.pagerView.register(UINib(nibName: String(describing: GifViewerCell.self), bundle: nil), forCellWithReuseIdentifier: "GifViewerCell5")
        self.pagerView.register(UINib(nibName: String(describing: GifViewerCell.self), bundle: nil), forCellWithReuseIdentifier: "GifViewerCell6")
        self.pagerView.register(UINib(nibName: String(describing: GifViewerCell.self), bundle: nil), forCellWithReuseIdentifier: "GifViewerCell7")
        self.pagerView.register(UINib(nibName: String(describing: GifViewerCell.self), bundle: nil), forCellWithReuseIdentifier: "GifViewerCell8")
        self.pagerView.register(UINib(nibName: String(describing: GifViewerCell.self), bundle: nil), forCellWithReuseIdentifier: "GifViewerCell9")
        self.pagerView.automaticSlidingInterval = 0
        self.pagerView.isInfinite = false;
        self.pagerView.isScrollEnabled = true
        self.pagerView.bounces = true;
        self.pagerView.itemSize = FSPagerView.automaticSize
        self.pagerView.itemSize = self.pagerView.frame.size.applying(CGAffineTransform(scaleX: 1.0, y: 1.0))
        self.pagerView.interitemSpacing = 0
        self.pagerView.scrollDirection = .horizontal
        self.pagerView.decelerationDistance = FSPagerView.automaticDistance
        self.pagerView.decelerationDistance = 1
    }
}


// MARK:- FSPagerView DataSource

extension GifViewerController: FSPagerViewDataSource {
    
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 9
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "GifViewerCell\(index+1)", at: index) as! GifViewerCell
        cell.anmView.isHidden = true
        
        if (index == 0) {
            /**
             * Lottie 파일 로드
             * https://github.com/airbnb/lottie-ios
             * https://lottiefiles.com/blog/working-with-lottie/how-to-add-lottie-animation-ios-app-swift
             * https://lottiefiles.com/
             */
            cell.anmView.contentMode = .scaleAspectFit
            cell.anmView.loopMode = .loop
            cell.anmView.animationSpeed = 1.0
            cell.anmView.play()
            cell.anmView.isHidden = false
            cell.txtView.text = "Lottie 라이브러리"
        }
        
        if (index == 1) {
            /**
             * png 파일 로드
             */
            cell.imgView.stopAnimating()
            self.animationImages.removeAll()
            for i in 0..<28 {
                if let image = UIImage(named: String(format: "snowfall_%02d_delay-0.03s", i)) {
                    self.animationImages.append(image)
                }
            }
            cell.imgView.animationImages = self.animationImages
            cell.imgView.animationDuration = 1.0
            cell.imgView.animationRepeatCount = 0
            cell.imgView.startAnimating()
            cell.txtView.text = "PNG 파일 로드"
        }
        
        if (index == 2) {
            /**
             * WebP 파일 로드 - 움직이는 webp 파일은 로드 에러 발생
             * https://github.com/visoom/WebP-Swift
             * https://developers.google.com/speed/webp/download
             */
            //let webp = UIImage(webpWithURL: URL(string: "https://www.gstatic.com/webp/gallery3/3_webp_ll.webp")!)
            //let webp = UIImage(webpWithURL: Bundle.main.url(forResource: "snowfall", withExtension: "webp")!)
            let filePath = Bundle.main.path(forResource: "snowfall", ofType: "webp")!
            //let webp = UIImage(webpWithPath: filePath)
            //cell.imgView.image = webp

            /**
             * SDWebImageWebPCoder 라이브러리 - 성능 좋음
             * https://github.com/SDWebImage/SDWebImageWebPCoder
             */
            cell.imgView.sd_setImage(with: URL(fileURLWithPath: filePath))

            /**
             * KingfisherWebP 라이브러리 - 성능 저하 문제, CPU/Memory 부하
             * https://github.com/Yeatse/KingfisherWebP
             */
            //cell.imgView.kf.setImage(with: URL(fileURLWithPath: filePath), options: [.processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)])

            /**
             * Nuke-WebP-Plugin 라이브러리 - 움직이는 webp 파일은 로드 하지 못하는 거 같음
             * https://github.com/ryokosuge/Nuke-WebP-Plugin
             */
            //WebPImageDecoder.enable()
            //Nuke.loadImage(with: Bundle.main.url(forResource: "snowfall", withExtension: "webp")!, into: cell.imgView)

            cell.txtView.text = "WebP 라이브러리"
        }

        if (index == 3) {
            /**
             * GIF 이미지 로드
             * https://github.com/kirualex/SwiftyGif
             */
            do {
                if cell.imgView.gifImage == nil {
                    let gif = try UIImage(gifName: "snowfall.gif")
                    cell.imgView.setGifImage(gif, loopCount: -1)
                }
                cell.imgView.startAnimatingGif()
            } catch {
                print(error)
            }
            cell.txtView.text = "SwiftyGif 라이브러리"
        }

        if (index == 4) {
            /**
             * GIF 이미지 로드
             * https://github.com/kaishin/Gifu
             */
            if cell.gifView.image == nil {
                cell.gifView.animate(withGIFNamed: "rainfall") {
                    print("It's animating!")
                }
            }
            cell.gifView.startAnimatingGIF()
            cell.txtView.text = "Gifu 라이브러리"
        }

        if (index == 5) {
            /**
             * GIF 이미지 로드
             * https://github.com/SDWebImage/SDWebImage
             */
            if cell.aniView.image == nil {
                cell.aniView.image = SDAnimatedImage(named: "snowfall.gif")
            }
            cell.aniView.startAnimating()
            cell.txtView.text = "SDWebImage 라이브러리"
        }

        if (index == 6) {
            /**
             * GIF 이미지 로드 - 큰 GIF 로드 시 메모리 문제 발생, 이미지 캐시 안쓰나??
             * https://github.com/TaLinh/JellyGif
             */
            if cell.jellyView.animator == nil {
                cell.jellyView.startGif(with: .name("rainfall"))
            }
            if cell.jellyView.animator?.isReady ?? true {
                cell.jellyView.animator?.startAnimation()
            } else {
                cell.jellyView.animator?.prepareAnimation()
            }
            cell.txtView.text = "JellyGif 라이브러리"
        }

        if (index == 7) {
            /**
             * GIF 이미지 로드 - 큰 GIF 로드 시 메모리 문제 발생, 비동기 로드가 되지 않음
             * https://github.com/swiftgif/SwiftGif
             * https://stackoverflow.com/questions/27919620/how-to-load-gif-image-in-swift
             */
            //let gif = UIImage.gif(url: "https://upload.wikimedia.org/wikipedia/commons/2/2c/Rotating_earth_%28large%29.gif")
            //cell.imgView.image = gif
            cell.imgView.image = nil
            cell.imgView.loadGif(name: "snowfall")
            cell.txtView.text = "Extension UIImageView GIF"
        }

        if (index == 8) {
            /**
             * GIF 이미지 로드 - 큰 GIF 로드 시 메모리 문제 발생
             * https://github.com/onevcat/Kingfisher
             */
            let path = Bundle.main.url(forResource: "rainfall", withExtension: "gif")!
            let resource = LocalFileImageDataProvider(fileURL: path)
            cell.imgView.kf.setImage(with: resource)
            cell.txtView.text = "Kingfisher 라이브러리"
        }
        
        return cell
    }
}


// MARK:- FSPagerView Delegate

extension GifViewerController: FSPagerViewDelegate {
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        print(targetIndex)
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        print(pagerView.currentIndex)
    }
}
