//
//  VIVRJuiceTagger.swift
//  vivr
//
//  Created by max blessen on 1/20/16.
//  Copyright © 2016 max blessen. All rights reserved.
//

import Foundation

class VIVRLink {
    var linkText:String?
    var startIndex:Int?
    var endIndex:Int?
    
    required init(startIndex: Int) {
        self.startIndex = startIndex
    }
    
    class func createTag(startIndex: Int) -> VIVRLink {
        let link = VIVRLink(startIndex: startIndex)
        return link
    }
}

class VIVRTagger {
    
    var linkCount:Int?
    var wordsArray: NSArray?
    var activeLinksArray: NSMutableArray = []
    var isEditingLink: Bool?
    var delegate:VIVRJuiceTaggerProtocol? = nil
    var currentLink: String?
    
    func watchForJuiceTag(textView: UITextView, text: String, range: NSRange, completion:(juiceTaggerActive: Bool) -> Void) {
        updateWordsArray(textView.text)
        if self.delegate != nil {
            if text == "@" {
                self.isEditingLink = true
                currentLink = "@"
                completion(juiceTaggerActive: true)
            }else if text == " " {
                completion(juiceTaggerActive: false)
                self.isEditingLink = false
                completeLink()
            }else if isEditingLink == true {
                    createLink(text)
                    completion(juiceTaggerActive: true)
            }
        }
    }
    
    class func createJuiceTaggerView() -> VIVRSearchViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("searchTable") as? VIVRSearchViewController
        viewController!.setupForJuiceTagger()
        return viewController!
    }
    
    func updateWordsArray(string: String) {
        let wordsArray = string.componentsSeparatedByString(" ")
        self.wordsArray = wordsArray
        var linkCount = 0
        for word:String in self.wordsArray as! [String] {
            if word.hasPrefix("@") {
                linkCount++
                self.linkCount = linkCount
            }
        }
    }
//    
//    func newestLink() -> String? {
//        for word: String in self.wordsArray as! [String] {
//            if word.hasPrefix("@") {
//                if !self.activeLinksArray.containsObject(word) {
//                    self.activeLinksArray.addObject(word)
//                    return word
//                }
//            }
//        }
//    }
    
    func createLink(string: String) {
        currentLink = currentLink! + string
    }
    
    func completeLink() {
        
    }
    
}