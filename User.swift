//
//  User.swift
//  FirstCourseFinalTask
//
//  Created by Калинин Артем Валериевич on 25.05.2020.
//  Copyright © 2020 E-Legion. All rights reserved.
//

import Foundation
import FirstCourseFinalTaskChecker

//MARK: - Class User
struct User: UserProtocol {
    
  let id: Self.Identifier
    
  let username: String
    
  let fullName: String
    
  let avatarURL: URL?
    
  var currentUserFollowsThisUser: Bool
    
  var currentUserIsFollowedByThisUser: Bool
    
  var followsCount: Int
    
  var followedByCount: Int
}
