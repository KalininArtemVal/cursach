//
//  main.swift
//  FirstCourseFinalTask
//
//  Copyright © 2017 E-Legion. All rights reserved.
//

import Foundation
import FirstCourseFinalTaskChecker


//MARK: - class UserStorageClass


class UserStorageClass: UsersStorageProtocol {
    
    var count: Int {
        get { return users.count }
        set {}
    }
    
    var users = [UserInitialData]()
    var followers: [(User.Identifier, User.Identifier)] // (Пользователь, подписка)
    private var currentUserID: GenericIdentifier<UserProtocol>
    private let currentUserData: UserInitialData
    
    required init?(
        users: [UserInitialData],
        followers: [(GenericIdentifier<UserProtocol>, GenericIdentifier<UserProtocol>)],
        currentUserID: GenericIdentifier<UserProtocol>
    ) {
        
        guard let currentUserData = users.first(where: { $0.id == currentUserID }) else { return nil }
        
        self.users = users
        self.followers = followers
        self.currentUserID = currentUserID
        self.currentUserData = currentUserData
    }
    
    // MARK: - Current User
    
    func currentUser() -> UserProtocol {
        
        var currentUser = User(id: currentUserID,
                               username: currentUserData.username,
                               fullName: currentUserData.fullName,
                               avatarURL: currentUserData.avatarURL,
                               currentUserFollowsThisUser: false,
                               currentUserIsFollowedByThisUser: false,
                               followsCount: 0,
                               followedByCount: 0)
        
        for follower in followers where currentUser.id == follower.0 {
            if currentUser.currentUserFollowsThisUser == true {
                currentUser.currentUserFollowsThisUser = false
            } else {
                currentUser.currentUserFollowsThisUser = true
            }
        }
        
        for follower in followers {
            if follower.0 == currentUserID {
                currentUser.followsCount += 1
            } else if follower.1 == currentUserID {
                currentUser.followedByCount += 1
            }
        }
        return currentUser
    }
    
    
    
    // MARK: - User
    
    func user(with userID: GenericIdentifier<UserProtocol>) -> UserProtocol? {
        for user in users where userID == user.id {
            var someUser = User(id: userID,
                                username: user.username,
                                fullName: user.fullName,
                                avatarURL: user.avatarURL,
                                currentUserFollowsThisUser: false,
                                currentUserIsFollowedByThisUser: false,
                                followsCount: 0,
                                followedByCount: 0)
            
            for follower in followers where someUser.id == follower.0 {
                if someUser.currentUserFollowsThisUser == true {
                    someUser.currentUserFollowsThisUser = false
                } else {
                    someUser.currentUserFollowsThisUser = true
                }
            }
            
            for follower in followers where someUser.id == follower.1 {
                if someUser.currentUserIsFollowedByThisUser == true {
                    someUser.currentUserIsFollowedByThisUser = false
                } else {
                    someUser.currentUserIsFollowedByThisUser = true
                }
            }
            
            for follower in followers {
                if follower.0 == someUser.id {
                    someUser.followsCount += 1
                } else if follower.1 == someUser.id {
                    someUser.followedByCount += 1
                }
            }
            return someUser
        }
        return nil
    }
    
    // MARK: - FindUsers.
    
    func findUsers(by searchString: String) -> [UserProtocol] {
        var ArrayOfFindingUsers = [UserProtocol]()
        for u in users {
            if u.username == searchString {
                if let searchingUser = user(with: u.id) {
                    ArrayOfFindingUsers.append(searchingUser)
                } else {
                    return []
                }
            }
        }
        return ArrayOfFindingUsers
    }
    
    // MARK: - Follow
    
    func follow(_ userIDToFollow: GenericIdentifier<UserProtocol>) -> Bool {
        for user in users where user.id == userIDToFollow {
            for follower in followers {
                if follower.1 == userIDToFollow {
                    return true
                } else {
                    followers.append((follower.0,userIDToFollow))
                    return true
                }
            }
            return false
        }
        return false
    }
    
    
    
    
    //MARK: - UnFollow. Отписка
    
    
    func unfollow(_ userIDToUnfollow: GenericIdentifier<UserProtocol>) -> Bool {
        for user in users where user.id == userIDToUnfollow {
            for (index, follower) in followers.enumerated() {
                if follower.0 == currentUserID {
                    followers.remove(at: index)
                    return true
                } else {
                    return true
                }
            }
            return false
        }
        return false
    }
    
    
    //MARK: - usersFollowingUser. Подписчики.
    
    func usersFollowingUser(with userID: GenericIdentifier<UserProtocol>) -> [UserProtocol]? {
        var arrayOfSearchingUsers = [UserProtocol]()
        for us in users where us.id == userID {
            for follower in followers where follower.1 == userID {
                if let searchingUser = user(with: follower.0){
                    arrayOfSearchingUsers.append(searchingUser)
                }
            }
            return arrayOfSearchingUsers
        }
        return nil
    }
    
    
    //MARK: - usersFollowedByUser он подписчик
    
    
    func usersFollowedByUser(with userID: GenericIdentifier<UserProtocol>) -> [UserProtocol]? {
        var arrayOfSearchingUsers = [UserProtocol]()
        for us in users where us.id == userID {
            for follower in followers where follower.0 == userID {
                if let searchingUser = user(with: follower.1){
                    arrayOfSearchingUsers.append(searchingUser)
                }
            }
            return arrayOfSearchingUsers
        }
        return nil
    }
}

//MARK: - class PostsStorageClass


class PostsStorageClass: PostsStorageProtocol {
    
    
    var posts: [PostInitialData]
    
    var likes: [(GenericIdentifier<UserProtocol>, GenericIdentifier<PostProtocol>)]
    
    var currentUserID: GenericIdentifier<UserProtocol>
    
    
    required init(posts: [PostInitialData], likes: [(GenericIdentifier<UserProtocol>, GenericIdentifier<PostProtocol>)], currentUserID: GenericIdentifier<UserProtocol>) {
        
        
        self.posts = posts
        self.likes = likes
        self.currentUserID = currentUserID
    }
    
    var count: Int {
        get { return posts.count }
        set {}
    }
    
    //MARK: - POST
    /// Возвращает публикацию с переданным ID.
    ///
    /// - Parameter postID: ID публикации которую нужно вернуть.
    /// - Returns: Публикация если она была найдена.
    /// nil если такой публикации нет в хранилище.
    
    func post(with postID: GenericIdentifier<PostProtocol>) -> PostProtocol? {
        
        for post in posts where post.id == postID {
            
            var searchingPost = Post(id: post.id,
                                     author: post.author,
                                     description: post.description,
                                     imageURL: post.imageURL,
                                     createdTime: post.createdTime,
                                     // Свойство, отображающее ставил ли текущий пользователь лайк на эту публикацию
                currentUserLikesThisPost: false,
                likedByCount: 0)
            
            
            
            for like in likes where like.1 == searchingPost.id && currentUserID == like.0  {
                searchingPost.currentUserLikesThisPost = true
                
            }
            
            for like in likes where like.1 == searchingPost.id {
                searchingPost.likedByCount += 1
            }
            
            
            
            return searchingPost
        }
        return nil
    }
    
    //MARK: - findPosts
    /// Возвращает все публикации пользователя с переданным ID.
    ///
    /// - Parameter authorID: ID пользователя публикации которого нужно вернуть.
    /// - Returns: Массив публикаций.
    /// Пустой массив если пользователь еще ничего не опубликовал.
    func findPosts(by authorID: GenericIdentifier<UserProtocol>) -> [PostProtocol] {
        var arrayOfPosts = [PostProtocol]()
        for p in posts where p.author == authorID {
            if let searchingPost = post(with: p.id) {
                arrayOfPosts.append(searchingPost)
            }
        }
        return arrayOfPosts
    }
    
    
    //MARK: - findPosts
    /// Возвращает все публикации, содержащие переданную строку.
    ///
    /// - Parameter searchString: Строка для поиска.
    /// - Returns: Массив публикаций.
    /// Пустой массив если нет таких публикаций.
    func findPosts(by searchString: String) -> [PostProtocol] {
        var arrayOfThePosts = [PostProtocol]()
        
        for p in posts where p.description == searchString {
            if let searchingPost = post(with: p.id) {
                arrayOfThePosts.append(searchingPost)
            }
        }
        return arrayOfThePosts
    }
    
    //MARK: - likePost
    /// Ставит лайк от текущего пользователя на публикацию с переданным ID.
    ///
    /// - Parameter postID: ID публикации на которую нужно поставить лайк.
    /// - Returns: true если операция выполнена упешно или пользователь уже поставил лайк
    /// на эту публикацию.
    /// false в случае если такой публикации нет.
    func likePost(with postID: GenericIdentifier<PostProtocol>) -> Bool {
        
        for post in posts where postID == post.id {
            for like in likes {
                if like.1 == postID {
                    return true
                } else {
                    return true
                }
                
            }
            return false
        }
        return false
    }
    
    
    
    //MARK: - unlikePost
    /// Удаляет лайк текущего пользователя у публикации с переданным ID.
    ///
    /// - Parameter postID: ID публикации у которой нужно удалить лайк.
    /// - Returns: true если операция выполнена успешно или пользователь и так не ставил лайк
    /// на эту публикацию.
    /// false в случае если такой публикации нет.
    func unlikePost(with postID: GenericIdentifier<PostProtocol>) -> Bool {
        var isLiked: Bool = true
        for like in likes {
            for post in posts {
                if post.id == like.1 {
                    let correctPost = post
                    if correctPost.id == postID {
                        isLiked = false
                    } else {
                        isLiked = true
                    }
                }
            }
        }
        return isLiked
    }
    
    //MARK: - usersLikedPost
    /// Возвращает ID пользователей поставивших лайк на публикацию.
    ///
    /// - Parameter postID: ID публикации лайки на которой нужно искать.
    /// - Returns: Массив ID пользователей.
    /// Пустой массив если никто еще не поставил лайк на эту публикацию.
    /// nil если такой публикации нет в хранилище.
    func usersLikedPost(with postID: GenericIdentifier<PostProtocol>) -> [GenericIdentifier<UserProtocol>]? {
        var arrayOfUsersID = [GenericIdentifier<UserProtocol>]()
        for like in likes {
            let userPostID = like.1
            if userPostID == postID {
                let userID = like.0
                arrayOfUsersID.append(userID)
            } else {
                return nil
            }
        }
        return arrayOfUsersID
    }
}

//MARK: - Проверка
let userStorageClass = UserStorageClass.self
let postsStorageClass = PostsStorageClass.self

let checker = Checker(usersStorageClass: userStorageClass,
                      postsStorageClass: postsStorageClass)
checker.run()
