//
//  TrimTranscriptController.swift
//  StoryPlus
//
//  Created by Alex Sanchez on 17/3/17.
//  Copyright © 2017 Alex Sanchez. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class TranscriptController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var languageCode = String()
    let reuseIdentifier = "cell"
    var thumbnails: [UIImage]?
    var videoURLs: [URL]?
    
    lazy var selectLanguage: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("LANGUAGE: By default", for: .normal)
        button.addTarget(self, action: #selector(showLanguagesController), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold)
        
        button.backgroundColor = UIColor.rgb(r: 88, g: 86, b: 214, a: 1)//rgb(52, 152, 219)
        button.setTitleColor(UIColor.white, for: .normal)
        return button
    }()
    
    lazy var transcriptVideo: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("TRANSCRIPT VIDEOS", for: .normal)
        //button.addTarget(self, action: #selector(trimOptions), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold)
        button.backgroundColor = UIColor.rgb(r: 245, g: 45, b: 85, a: 1)//rgb(52, 152, 219)
        button.setTitleColor(UIColor.white, for: .normal)
        return button
    }()
    
    lazy var videosCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let reminder = self.view.frame.width.truncatingRemainder(dividingBy: 4)
        let size = (self.view.frame.width / 4) - (reminder / 4)
        
        layout.itemSize = CGSize(width: size, height: size)
        layout.sectionInset = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(VideoCell.self, forCellWithReuseIdentifier: "cell")
        collection.backgroundColor = UIColor.white
        collection.translatesAutoresizingMaskIntoConstraints = false
        
        return collection
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        videosCollectionView.delegate = self
        videosCollectionView.dataSource = self
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Language code: " + languageCode)
    }
    
    func setupViews(){
        
        view.addSubview(transcriptVideo)
        transcriptVideo.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        transcriptVideo.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        transcriptVideo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        transcriptVideo.heightAnchor.constraint(equalToConstant: 72).isActive = true
        
        view.addSubview(selectLanguage)
        selectLanguage.bottomAnchor.constraint(equalTo: transcriptVideo.topAnchor).isActive = true
        selectLanguage.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        selectLanguage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        selectLanguage.heightAnchor.constraint(equalToConstant: 72).isActive = true
        
        view.addSubview(videosCollectionView)
        videosCollectionView.bottomAnchor.constraint(equalTo: selectLanguage.topAnchor).isActive = true
        videosCollectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        videosCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        videosCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
    
    func showLanguagesController(){
        let languagesController = LanguagesController()
        languagesController.transcriptController = self
        let navigation = UINavigationController(rootViewController: languagesController)
        self.present(navigation, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = thumbnails?.count {
            return count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! VideoCell
        cell.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        cell.videoImageView.image = thumbnails?[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = videoURLs?[indexPath.row] {
            playVideo(url: url)
        }
    }
    
    func playVideo(url: URL){
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    

}
