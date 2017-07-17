//
//  Models.swift
//  alamofireTest
//
//  Created by Veronika Hristozova on 7/4/17.
//  Copyright © 2017 Veronika Hristozova. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import ObjectMapper


//Book model
struct Book: Mappable {
    var id: Int = 0
    var name: String = ""
    var price: Double = 0
    var author: String = ""
    var pictureURL: String?
    var description: String?
    
    var imageDownloadCompletion: ((UIImage) -> Void)?
    
    init?(map: Map) {}
   
    mutating func mapping(map: Map) {
        id <- map["Id"]
        name <- map["Name"]
        price <- map["Price"]
        author <- map["Author"]
        pictureURL <- map["PictureURL"]
        description <- map["Description"]
    }
}


//Example usage of async downloading image, or retrive from cached.
class cellClass {
    
    var imageView = UIImageView()
    
    func tryDownload() {
        imageView.af_setImage(withURL: URL(string: "")!, placeholderImage: #imageLiteral(resourceName: "xplosion"), progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(2), runImageTransitionIfCached: true) { response in
            //
        }
        
//        //these can be nested to download diff images
//        imageView.af_setImage(withURL: <#T##URL#>, placeholderImage: nil, filter: nil, progress: { progress in
//            //check the progress
//        }, progressQueue: .main, imageTransition: <#T##UIImageView.ImageTransition#>, runImageTransitionIfCached: true, completion: nil)
        //imageView.af_setImage(withURL: <#T##URL#>, placeholderImage: <#T##UIImage?#>, filter: <#T##ImageFilter?#>, progress: <#T##ImageDownloader.ProgressHandler?##ImageDownloader.ProgressHandler?##(Progress) -> Void#>, progressQueue: <#T##DispatchQueue#>, imageTransition: <#T##UIImageView.ImageTransition#>, runImageTransitionIfCached: <#T##Bool#>, completion: <#T##((DataResponse<UIImage>) -> Void)?##((DataResponse<UIImage>) -> Void)?##(DataResponse<UIImage>) -> Void#>)
    }
    
    func prepareForReuse() {
        imageView.af_cancelImageRequest()
        imageView.layer.removeAllAnimations()
        imageView.image = nil
    }
}



