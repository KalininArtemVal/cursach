//
//  main.swift
//  FirstCourseFinalTask
//
//  Copyright © 2017 E-Legion. All rights reserved.
//

import Foundation
import FirstCourseFinalTaskChecker


//MARK: - class UserStorageClass
/// Инициализатор хранилища. Принимает на вход массив пользователей, массив подписок в
/// виде кортежей в котором первый элемент это ID, а второй - ID пользователя на которого он
/// должен быть подписан и ID текущего пользователя.
/// Инициализация может завершится с ошибкой если пользователя с переданным ID
/// нет среди пользователей в массиве users.

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
    /// Возвращает текущего пользователя
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
    /// Возвращает пользователя с переданным ID.
    ///
    /// - Parameter userID: ID пользователя которого нужно вернуть.
    /// - Returns: Пользователь если он был найден.
    /// nil если такого пользователя нет в хранилище.
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
            // (Пользователь, подписка)
            //если текущий пользователь на него не подписан.
            for follower in followers where someUser.id == follower.0 {
                if someUser.currentUserFollowsThisUser == true {
                    someUser.currentUserFollowsThisUser = false
                } else {
                    someUser.currentUserFollowsThisUser = true
                }
            }
     //должен возвращать пользователя с followsCount равным нулю если это пользователь ни на кого не подписан.

            
            
            
            for follower in followers where someUser.id == follower.1 {
                if someUser.currentUserIsFollowedByThisUser == true {
                    someUser.currentUserIsFollowedByThisUser = false
                } else {
                    someUser.currentUserIsFollowedByThisUser = true
                }
            }
            //Текущий пользователь должен иметь followsCount с учетом позже добавленных подписок через follow()
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
    
    /// Возвращает всех пользователей, содержащих переданную строку.
    ///
    /// - Parameter searchString: Строка для поиска.
    /// - Returns: Массив пользователей. Если не нашлось ни одного пользователя, то пустой массив.
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
    
    ///Добавляет текущего пользователя в подписчики.
    /// - Parameter userIDToFollow: ID пользователя на которого должен подписаться текущий пользователь.
    /// - Returns: true если текущий пользователь стал подписчиком пользователя с переданным ID
    /// или уже являлся им.
    /// false в случае если в хранилище нет пользователя с переданным ID.
    func follow(_ userIDToFollow: GenericIdentifier<UserProtocol>) -> Bool {
        for follower in followers where follower.1 == userIDToFollow {
            return true
        }
        return false
    }
    
    //MARK: - UnFollow. Отписка
    
    func unfollow(_ userIDToUnfollow: GenericIdentifier<UserProtocol>) -> Bool {
        for follower in followers where follower.1 != userIDToUnfollow {
                return true
            }
            return false
        }
    
    //MARK: - usersFollowingUser. Подписчики.
    
    /// Возвращает всех подписчиков пользователя.
    ///
    /// - Parameter userID: ID пользователя подписчиков которого нужно вернуть.
    /// - Returns: Массив пользователей.
    /// Пустой массив если на пользователя никто не подписан.
    /// nil если такого пользователя нет.
    
    func usersFollowingUser(with userID: GenericIdentifier<UserProtocol>) -> [UserProtocol]? {
        var arrayOfSearchingUsers = [UserProtocol]()
        for u in users where u.id == userID {
            for follower in followers where u.id == follower.1 {
                if let searchingUser = user(with: follower.0) {
                    arrayOfSearchingUsers.append(searchingUser)
                }
            }
        }
        return arrayOfSearchingUsers
    }
//        for follower in followers {
//            for u in users {
//                if u.id == userID {
//                    if u.id == follower.1 {
//                        if let searchingUser = user(with: follower.0) {
//                            arrayOfSearchingUsers.append(searchingUser)
//                        } else {
//                            return []
//                        }
//                    }
//                } else {
//                    return []
//                }
//            }
//        }
//        return arrayOfSearchingUsers
//    }
    
    //MARK: - usersFollowedByUser он подписчик
    
    /// Возвращает все подписки пользователя.
    ///
    /// - Parameter userID: ID пользователя подписки которого нужно вернуть.
    /// - Returns: Массив пользователей.
    /// Пустой массив если он ни на кого не подписан.
    /// nil если такого пользователя нет.
    
    //он подписчик
    func usersFollowedByUser(with userID: GenericIdentifier<UserProtocol>) -> [UserProtocol]? {
        // (Пользователь, подписка)
        var arrayOfSearchingUsers = [UserProtocol]()
        for follower in followers {
            for u in users {
                if u.id == userID {
                    if u.id == follower.0 {
                        if let searchingUser = user(with: follower.1) {
                            arrayOfSearchingUsers.append(searchingUser)
                        } else {
                            return []
                        }
                    }
                } else {
                    return nil
                }
            }
        }
        return arrayOfSearchingUsers
    }
}

//MARK: - class PostsStorageClass

/// Инициализатор хранилища. Принимает на вход массив публикаций, массив лайков в виде
/// кортежей в котором первый - это ID пользователя, поставившего лайк, а второй - ID публикации
/// на которой должен стоять этот лайк и ID текущего пользователя.

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
            
            // если текущий пользователь поставил лайк на публикацию с переданным ID
            
            for like in likes where like.1 == searchingPost.id && currentUserID == like.0 {
                        searchingPost.currentUserLikesThisPost = true
                
            }
//            for like in likes where like.0 != currentUserID {
//                if likePost(with: searchingPost.id) {
//                    searchingPost.currentUserLikesThisPost = false
//                } else {
//                    searchingPost.currentUserLikesThisPost = true
//                }
//            }
            
                //(пользователь, публикация)
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
            return true
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
