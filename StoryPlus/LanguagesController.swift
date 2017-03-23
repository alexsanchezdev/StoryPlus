//
//  LanguagesController.swift
//  StoryPlus
//
//  Created by Alex Sanchez on 22/3/17.
//  Copyright © 2017 Alex Sanchez. All rights reserved.
//

import UIKit

class LanguagesController: UITableViewController {
    
    var transcriptController: TranscriptController?
    
    let languagesArray = ["Arabic", "Catalan", "Chinese", "Danish", "Dutch", "English", "Finnish", "French", "German", "Italian", "Japanese", "Korean", "Norwegian", "Polish", "Portuguese", "Russian", "Spanish", "Swedish"]
    let languagesCodes = ["ar", "ca", "zh", "da", "nl", "en", "fi", "fr", "de" , "it", "ja", "ko", "no", "pl", "pt", "ru", "es", "sv"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeController))
        navigationItem.rightBarButtonItem = button
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = languagesArray[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languagesArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        transcriptController?.selectLanguage.setTitle("LANGUAGE: \(languagesArray[indexPath.row])", for: .normal)
        transcriptController?.languageCode = languagesCodes[indexPath.row]
        self.dismiss(animated: true, completion: nil)
    }
    
    func closeController(){
        self.dismiss(animated: true, completion: nil)
    }
}
