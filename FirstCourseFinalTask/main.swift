//
//  main.swift
//  FirstCourseFinalTask
//
//  Copyright © 2017 E-Legion. All rights reserved.
//

import Foundation
import FirstCourseFinalTaskChecker



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
    var followers: [(User.Identifier, User.Identifier)]
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


    /// Возвращает текущего пользователя
    func currentUser() -> UserProtocol {
        return User(
            id: currentUserID,
            username: currentUserData.username,
            fullName: currentUserData.fullName,
            avatarURL: currentUserData.avatarURL,
            /// Свойство, отображающее подписан ли текущий пользователь на этого пользователя
            currentUserFollowsThisUser: follow(currentUserID),//(usersFollowedByUser(with: currentUserID) != nil), // он подписан
            /// Свойство, отображающее подписан ли этот пользователь на текущего пользователя
            currentUserIsFollowedByThisUser: (usersFollowingUser(with: currentUserID) != nil), // подписчики
            followsCount: usersFollowedByUser(with: currentUserID)?.count ?? 0,//количестов подписок
            followedByCount: usersFollowingUser(with: currentUserID)?.count ?? 0 // Количество подписчиков
        )
    }


    /// Возвращает пользователя с переданным ID.
    ///
    /// - Parameter userID: ID пользователя которого нужно вернуть.
    /// - Returns: Пользователь если он был найден.
    /// nil если такого пользователя нет в хранилище.
    
    func user(with userID: GenericIdentifier<UserProtocol>) -> UserProtocol? {
        var searchingUser = currentUser()
        for user in users {
//            let user = user
            if user.id == userID {
            let someUser = User(
                id: userID,
                username: user.username,
                fullName: user.fullName,
                avatarURL: user.avatarURL,
                currentUserFollowsThisUser: (usersFollowedByUser(with: userID) != nil),
                currentUserIsFollowedByThisUser:  (usersFollowingUser(with: userID) != nil),
                followsCount: usersFollowedByUser(with: userID)?.count ?? 0,
                followedByCount: usersFollowingUser(with: userID)?.count ?? 0
            )
                searchingUser = someUser
            } else {
                return nil
            }
        }
        return searchingUser
    }
    //-------------------
    
    /// Возвращает всех пользователей, содержащих переданную строку.
    ///
    /// - Parameter searchString: Строка для поиска.
    /// - Returns: Массив пользователей. Если не нашлось ни одного пользователя, то пустой массив.
    func findUsers(by searchString: String) -> [UserProtocol] {
        var ArrayOfFindingUsers = [UserProtocol]()
        for u in users {
            if u.username == searchString {
                let searchingUser = user(with: u.id)
                ArrayOfFindingUsers.append(searchingUser!)
            }
        }
        return ArrayOfFindingUsers
    }

    /// Добавляет текущего пользователя в подписчики.
    ///
    /// - Parameter userIDToFollow: ID пользователя на которого должен подписаться текущий пользователь.
    /// - Returns: true если текущий пользователь стал подписчиком пользователя с переданным ID
    /// или уже являлся им.
    /// false в случае если в хранилище нет пользователя с переданным ID.
    func follow(_ userIDToFollow: GenericIdentifier<UserProtocol>) -> Bool {
        var isFollow: Bool = true
        for follower in followers {
            if follower.1 == userIDToFollow {
                isFollow = true
            } else {
                isFollow = false
            }
        }
        return isFollow
    }


    func unfollow(_ userIDToUnfollow: GenericIdentifier<UserProtocol>) -> Bool {
        var isFollow: Bool = true
        for folower in followers {
            if folower.1 != userIDToUnfollow {
                isFollow = false
                return isFollow
            } else {
                isFollow = true
                return true
            }
        }
        return isFollow
    }
    
    /// Возвращает всех подписчиков пользователя.
    ///
    /// - Parameter userID: ID пользователя подписчиков которого нужно вернуть.
    /// - Returns: Массив пользователей.
    /// Пустой массив если на пользователя никто не подписан.
    /// nil если такого пользователя нет.
    
    //подписчики
    func usersFollowingUser(with userID: GenericIdentifier<UserProtocol>) -> [UserProtocol]? {
        var arrayOfSearchingUsers = [UserProtocol]()
        for follower in followers {
            for someUser in users {
                if follower.1 == someUser.id {
                    if someUser.id == userID {
                        let searchingUser = user(with: someUser.id)
                        arrayOfSearchingUsers.append(searchingUser!)
                    } else {
                        return nil
                    }
                } else if arrayOfSearchingUsers.isEmpty {
                    return arrayOfSearchingUsers
                }
            }
        }
        return arrayOfSearchingUsers
    }
    
    
    /// Возвращает все подписки пользователя.
    ///
    /// - Parameter userID: ID пользователя подписки которого нужно вернуть.
    /// - Returns: Массив пользователей.
    /// Пустой массив если он ни на кого не подписан.
    /// nil если такого пользователя нет.
    
    
    //он подписчик
    func usersFollowedByUser(with userID: GenericIdentifier<UserProtocol>) -> [UserProtocol]? {
        var arrayOfSearchingUsers = [UserProtocol]()
        
        for follower in followers {
            for user in users {
                if user.id == follower.1 {
                    let followUser = user as? UserProtocol
                    arrayOfSearchingUsers.append(followUser!)
                } else if arrayOfSearchingUsers.isEmpty {
                    return arrayOfSearchingUsers
                } else if user.id != follower.1 {
                    return nil
                }
            }
        }
        return arrayOfSearchingUsers
    }
}


class PostsStorageClass: PostsStorageProtocol {
    /// Инициализатор хранилища. Принимает на вход массив публикаций, массив лайков в виде
    /// кортежей в котором первый - это ID пользователя, поставившего лайк, а второй - ID публикации
    /// на которой должен стоять этот лайк и ID текущего пользователя.
    
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
    
    /// Возвращает публикацию с переданным ID.
    ///
    /// - Parameter postID: ID публикации которую нужно вернуть.
    /// - Returns: Публикация если она была найдена.
    /// nil если такой публикации нет в хранилище.
    func post(with postID: GenericIdentifier<PostProtocol>) -> PostProtocol? {
        var arrayOfSearchingPosts = [PostProtocol]()
        for post in posts {
            if post.id == postID {
                let searchingPost = Post(id: postID,
                            author: post.author,
                            description: post.description,
                            imageURL: post.imageURL,
                            createdTime: post.createdTime,
                            currentUserLikesThisPost: likePost(with: postID),
                            likedByCount: usersLikedPost(with: postID)?.count ?? 0)
                arrayOfSearchingPosts.append(searchingPost)
            } else {
                return nil
            }
        }
        let takePost = arrayOfSearchingPosts[0]
        return takePost
    }
    
    /// Возвращает все публикации пользователя с переданным ID.
    ///
    /// - Parameter authorID: ID пользователя публикации которого нужно вернуть.
    /// - Returns: Массив публикаций.
    /// Пустой массив если пользователь еще ничего не опубликовал.
    func findPosts(by authorID: GenericIdentifier<UserProtocol>) -> [PostProtocol] {
        var arrayOfPosts = [PostProtocol]()
        for post in posts {
            if post.author == authorID {
                let searchingPost = Post(id: post.id,
                                         author: post.author,
                                         description: post.description,
                                         imageURL: post.imageURL,
                                         createdTime: post.createdTime,
                                         currentUserLikesThisPost: (usersLikedPost(with: post.id) != nil),
                                         likedByCount: (usersLikedPost(with: post.id)?.count)!)
                arrayOfPosts.append(searchingPost)
                return arrayOfPosts
            } else {
                return arrayOfPosts
            }
        }
        return arrayOfPosts
    }
    
    
    /// Возвращает все публикации пользователя с переданным ID.
    ///
    /// - Parameter authorID: ID пользователя публикации которого нужно вернуть.
    /// - Returns: Массив публикаций.
    /// Пустой массив если пользователь еще ничего не опубликовал.
    func findPosts(by searchString: String) -> [PostProtocol] {
        var arrayOfThePosts = [PostProtocol]()
        
        for p in posts {
            if p.description == searchString {
                let searchingPost = post(with: p.id)
                arrayOfThePosts.append(searchingPost!)
            } else {
                return arrayOfThePosts
            }
        }
        return arrayOfThePosts
    }
    
    /// Ставит лайк от текущего пользователя на публикацию с переданным ID.
    ///
    /// - Parameter postID: ID публикации на которую нужно поставить лайк.
    /// - Returns: true если операция выполнена упешно или пользователь уже поставил лайк
    /// на эту публикацию.
    /// false в случае если такой публикации нет.
    func likePost(with postID: GenericIdentifier<PostProtocol>) -> Bool {
        var isLiked: Bool = true
        for like in likes {
            for post in posts {
                if post.id == like.1 {
                    let correctPost = post
                    if correctPost.id == postID {
                        isLiked = true
                    } else {
                        isLiked = false
                    }
                }
            }
        }
        return isLiked
    }
    
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


let userStorageClass = UserStorageClass.self
let postsStorageClass = PostsStorageClass.self

let checker = Checker(usersStorageClass: userStorageClass,
                      postsStorageClass: postsStorageClass)
checker.run()
