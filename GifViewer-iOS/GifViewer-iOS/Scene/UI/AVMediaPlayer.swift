//
//  AVMediaPlayer.swift
//  GifViewer
//
//  Created by Chang-Hoon Han on 2020/08/03.
//  Copyright © 2020 Chang-Hoon Han. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class VideoView: UIView {

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    open override var contentMode: UIView.ContentMode {
        didSet {
            switch self.contentMode {
                case .scaleAspectFit:
                    self.playerLayer.videoGravity = .resizeAspect
                case .scaleAspectFill:
                    self.playerLayer.videoGravity = .resizeAspectFill
                default:
                    self.playerLayer.videoGravity = .resize
            }
        }
    }
}

protocol AVMediaPlayerDelegate {
    func onReady()
    func onLoaded(progress: Double)
    func onUpdate(progress: Double)
    func onFinish()
    func onFailed()
}

/**
 * AVPlayer
 * https://stackoverflow.com/questions/25348877/how-to-play-a-local-video-with-swift
 * https://theswiftdev.com/picking-and-playing-videos-in-swift/
 */
class AVMediaPlayer : NSObject {
    
    var delegate: AVMediaPlayerDelegate?
    
    enum `Type` {
        case audio
        case video
    }
    private var playerType: Type = .video
    private var videoView: VideoView?
    private let context: UnsafeMutableRawPointer? = nil
    private var player: AVPlayer?
    private var duration: Double = 0
    private var autoPlay: Bool = true
    private var `repeat`: Bool = true
    
    var playerRate: Float = 1 {
        didSet {
            if let player = player {
                player.rate = playerRate > 0 ? playerRate : 0.0
            }
        }
    }

    var volume: Float = 1.0 {
        didSet {
            if let player = player {
                player.volume = volume > 0 ? volume : 0.0
            }
        }
    }
    
    var callback: (() -> Void)? = { () -> () in }

    override init() {
        super.init()
    }
    
    convenience init(url: URL, view: VideoView? = nil, videoGravity: AVLayerVideoGravity? = nil, autoPlay: Bool = true, repeat: Bool = true, callback: (() -> Void)?) {
        self.init()
        self.playerType = view == nil ? .audio : .video
        self.videoView = view
        self.autoPlay = autoPlay
        self.repeat = `repeat`
        self.callback = callback
        
        if let playView = self.videoView, let playerLayer = playView.layer as? AVPlayerLayer, let videoGravity = videoGravity {
            playerLayer.videoGravity = videoGravity//AVLayerVideoGravity.resizeAspect
        }
        self.prepare(url: url, playerType: self.playerType)
    }

    private func prepare(url: URL, playerType: Type) {
        destory()
        let keys = ["tracks"]
        let asset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey : true])
        asset.loadValuesAsynchronously(forKeys: keys, completionHandler: {
            DispatchQueue.main.async {
                var error: NSError?
                let status: AVKeyValueStatus = asset.statusOfValue(forKey: "tracks", error: &error)
                if status == AVKeyValueStatus.loaded {
                    let item = AVPlayerItem(asset: asset)
                    item.addObserver(self, forKeyPath: "status", options: .initial, context: self.context)
                    item.addObserver(self, forKeyPath: "loadedTimeRanges", options: [.new, .old], context: self.context)
                    NotificationCenter.default.addObserver(self, selector: #selector(self.didReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
                    NotificationCenter.default.addObserver(self, selector: #selector(self.didFailedToPlayToEnd), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
                    if playerType == .video {
                        let output = AVPlayerItemVideoOutput(pixelBufferAttributes: [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)])
                        item.add(output)
                    }
                    item.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithm.varispeed
                    
                    self.player = AVPlayer(playerItem: item)
                    if let player = self.player {
                        player.rate = self.playerRate
                        let timeInterval = CMTimeMake(value: 1, timescale: 1)
                        player.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main, using: { (time) in
                            let timeNow = CMTimeGetSeconds(player.currentTime())
                            let progress = timeNow / self.duration
                            self.delegate?.onUpdate(progress: progress)
                        })
                    }
                    if let videoView = self.videoView, let layer = videoView.layer as? AVPlayerLayer {
                        layer.player = self.player
                        print("Player created...")
                    }
                    self.duration = CMTimeGetSeconds(asset.duration)
                }
            }
        })
    }

    deinit {
        destory()
    }

    func isPlaying() -> Bool {
        return player?.rate ?? 0 > 0
    }

    func pause() {
        player?.pause()
    }

    func play() {
        if let player = player {
            if (player.currentItem?.status == .readyToPlay) {
                player.play()
                player.rate = playerRate
            }
        }
    }

    func seekTo(seconds: Float64) {
        if let player = player {
            pause()
            if let timeScale = player.currentItem?.asset.duration.timescale {
                player.seek(to: CMTimeMakeWithSeconds(seconds, preferredTimescale: timeScale), completionHandler: { (complete) in
                    self.play()
                })
            }
        }
    }

    func destory() {
        seekTo(seconds: 0)
        if let item = player?.currentItem {
            item.removeObserver(self, forKeyPath: "status")
            item.removeObserver(self, forKeyPath: "loadedTimeRanges")
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: item)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: item)
            NotificationCenter.default.removeObserver(self)
        }
        player = nil
    }

    @objc private func didReachEnd() {
        delegate?.onFinish()
        player?.seek(to: CMTime.zero)
        if `repeat` {
            play()
        }
    }

    @objc private func didFailedToPlayToEnd() {
        destory()
        delegate?.onFailed()
    }
    

    // MARK: - Observations
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == self.context {
            if let key = keyPath {
                if key == "status", let player = player {
                    if player.status == .readyToPlay {
                        volume = player.volume
                        if autoPlay && player.rate == 0.0 {
                            play()
                        }
                        delegate?.onReady()
                        callback?()
                    } else if player.status == .failed {
                        print("Failed to load video")
                        destory()
                    }
                } else if key == "loadedTimeRanges", let item = player?.currentItem {
                    var maximum: TimeInterval = 0
                    for value in item.loadedTimeRanges {
                        let range: CMTimeRange = value.timeRangeValue
                        let currentLoadedTimeRange = CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration)
                        if currentLoadedTimeRange > maximum {
                            maximum = currentLoadedTimeRange
                        }
                    }
                    let progress: Double = duration == 0 ? 0.0 : Double(maximum) / duration
                    delegate?.onLoaded(progress: progress)
                }
            }
        }
    }
}
