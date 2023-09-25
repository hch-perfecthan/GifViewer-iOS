//
//  GifViewerCell.swift
//  GifViewer
//
//  Created by Chang-Hoon Han on 2020/08/03.
//  Copyright © 2020 Chang-Hoon Han. All rights reserved.
//

import UIKit
import FSPagerView
import Lottie
import SDWebImage
import Gifu
import JellyGif

class GifViewerCell: FSPagerViewCell {

    @IBOutlet weak var txtView: UILabel!
    @IBOutlet weak var anmView: AnimationView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var aniView: SDAnimatedImageView!
    @IBOutlet weak var gifView: GIFImageView!
    @IBOutlet weak var jellyView: JellyGifImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 기본적으로 설정되는 그림자 제거
        self.contentView.layer.shadowColor = nil
        self.contentView.layer.shadowRadius = 0
        self.contentView.layer.shadowOpacity = 0
        self.contentView.layer.shadowOffset = .zero
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        txtView.text = nil
    }
}
