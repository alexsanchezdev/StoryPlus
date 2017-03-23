//
//  VideoCell.swift
//  StoryPlus
//
//  Created by Alex Sanchez on 23/3/17.
//  Copyright © 2017 Alex Sanchez. All rights reserved.
//

import UIKit

class VideoCell: UICollectionViewCell {
    
    let videoImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //UIColor.rgb(r: 239, g: 239, b: 244, a: 1)
        setupViews()
    }
    
    func setupViews(){
        
        addSubview(videoImageView)
        videoImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        videoImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        videoImageView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        videoImageView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
