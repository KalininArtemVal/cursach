//
//  Post.swift
//  FirstCourseFinalTask
//
//  Created by Калинин Артем Валериевич on 26.05.2020.
//  Copyright © 2020 E-Legion. All rights reserved.
//

import Foundation
import FirstCourseFinalTaskChecker
//MARK: - Class Post
struct Post: PostProtocol {
    
    var id: Identifier
    
    var author: GenericIdentifier<UserProtocol>
    
    var description: String
    
    var imageURL: URL
    
    var createdTime: Date
    
    var currentUserLikesThisPost: Bool
    
    var likedByCount: Int
       
}
