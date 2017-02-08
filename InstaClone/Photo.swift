//
//  Photo.swift
//  InstaClone
//
//  Created by Tong Lin on 2/8/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

class Photo {
    let photoID: String
    let uploadedBy: String
    let title: String
    let category: String
    let filePath: String
    let date: String
    let time: String
    var upCount: Int
    var downCount: Int
    
    init(photoID: String, uploadedBy: String, title: String, category: String, filePath: String, date: String, time: String, upCount: Int, downCount: Int) {
        self.photoID = photoID
        self.uploadedBy = uploadedBy
        self.title = title
        self.category = category
        self.filePath = filePath
        self.date = date
        self.time = time
        self.upCount = upCount
        self.downCount = downCount
    }
    
    static func createPhotoInDatabase(for title: String, category: String, imagePath: String) {
        let date = Date()
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateStringFormatter.string(from: date)
        dateStringFormatter.dateFormat = "HH:mm:ss"
        let timeString = dateStringFormatter.string(from: date)
        
        let databasePhotoReference = FIRDatabase.database().reference().child("photos")
        let databaseUserReference = FIRDatabase.database().reference().child("users")
        
        // creating object in Photos node
        let photoRef = databasePhotoReference.childByAutoId()
        

        let uploadedPhoto = Photo(photoID: URL(string: photoRef.description())!.lastPathComponent, uploadedBy: FIRAuth.auth()!.currentUser!.uid, title: title, category: category, filePath: imagePath, date: dateString, time: timeString, upCount: 0, downCount: 0)
        
        let photoDetails : [String : AnyObject] = [
            "filePath" : uploadedPhoto.filePath as AnyObject,
            "date" : uploadedPhoto.date as AnyObject,
            "time" : uploadedPhoto.time as AnyObject,
            "title" : uploadedPhoto.title as AnyObject,
//            "votes" : uploadedPhoto.votes as AnyObject,
            "uploadedBy" : uploadedPhoto.uploadedBy as AnyObject,
            "category" : uploadedPhoto.category as AnyObject
        ]
        
        photoRef.setValue(photoDetails)
        
        let voteRef = photoRef.child("votes")
        let initalVoteCount : [String : AnyObject] = [
            "upvotes" : uploadedPhoto.upCount as AnyObject,
            "downvotes" : uploadedPhoto.downCount as AnyObject
        ]
        voteRef.updateChildValues(initalVoteCount)
        
        // adding the photo ID to user's photo bucket
        let userPhotoDirectory = databaseUserReference.child(FIRAuth.auth()!.currentUser!.uid).child("photos")
        let directoryAsURL = URL(string: photoRef.description())!
        let userPhotoDetail : [String : AnyObject ] = [
            directoryAsURL.lastPathComponent : "\(uploadedPhoto.date)-\(uploadedPhoto.time)" as AnyObject
        ]
        
        userPhotoDirectory.updateChildValues(userPhotoDetail)
    }
    
    static func uploadSuccess(_ metadata: FIRStorageMetadata, storagePath: String) {
        print("Upload Succeeded!")
        //        self.urlTextView.text = metadata.downloadURL()?.absoluteString
        
//        self.outPutText += "\(metadata.downloadURL()?.absoluteString)\n\n"
//        self.urlTextView.text = self.outPutText
        UserDefaults.standard.set(storagePath, forKey: "storagePath")
        UserDefaults.standard.synchronize()
        //        self.downloadPicButton.isEnabled = true
        
        print(metadata.bucket)
        print(metadata.downloadURL())
        print(metadata.downloadURLs)
        print(metadata.path)
        print(metadata.timeCreated)
    }
    
}