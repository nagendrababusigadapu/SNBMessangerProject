//
//  FileStorage.swift
//  SNBMessanger
//
//  Created by opasa on 22/03/21.
//

import Foundation
import FirebaseStorage
import ProgressHUD

let storage = Storage.storage()

class FileStorage {
    
    //MARK:- Image
    
    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String) -> Void){
        
        let storageRef = storage.reference().child(directory)
        
        let imageData = image.jpegData(compressionQuality: 0.6)
        
        var task: StorageUploadTask!
        
        task = storageRef.putData(imageData!, metadata: nil, completion: { (metaData, error) in
            
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil{
                print("Error uploading image \(error!.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { url, error in
                guard let downloadUrl = url else {
                    completion("")
                    return
                }
                
                completion(downloadUrl.absoluteString)
            }
        })
        
        task.observe(StorageTaskStatus.progress) { snapShot in
            let progress = Int(snapShot.progress!.completedUnitCount)/Int(snapShot.progress!.totalUnitCount)
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }
    
    class func downloadImage(imageUrl:String, completion: @escaping (_ image:UIImage?) -> Void){
        let imageFileName = fileNameFrom(fileUrl: imageUrl)
        if fileExistsAtPath(path: imageFileName){
            //get it locally
            if let contentOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)){
                completion(contentOfFile)
            }else{
                print("couldn't convert to local image")
                completion(UIImage(named: "avatar")!)
            }
        }else{
            //download from firebase
            if imageUrl != ""{
                let documentUrl = URL(string: imageUrl)
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
                downloadQueue.async {
                    let data = NSData(contentsOf: documentUrl!)
                    if data != nil{
                        // save locally
                        FileStorage.saveFileLocally(fileData: data!, fileName: imageFileName)
                        DispatchQueue.main.async {
                            completion(UIImage(data: data! as Data))
                        }
                    }else{
                        print("couldn't download image from DB")
                        completion(nil)
                    }
                }
            }
        }
    }
    
    class func saveFileLocally(fileData:NSData, fileName: String){
        
        let docUrl = getDocumentURL().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: docUrl, atomically: true)
    }
}

//Helpers

func fileInDocumentsDirectory(fileName: String) -> String {
    return getDocumentURL().appendingPathComponent(fileName).path
}

func getDocumentURL() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func fileExistsAtPath(path:String) -> Bool{
    return FileManager.default.fileExists(atPath: fileInDocumentsDirectory(fileName: path))
}
