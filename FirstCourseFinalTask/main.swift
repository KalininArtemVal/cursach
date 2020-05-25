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
      
    required init?(users: [UserInitialData], followers: [(GenericIdentifier<UserProtocol>, GenericIdentifier<UserProtocol>)], currentUserID: GenericIdentifier<UserProtocol>) {
        
        guard let currentUserData = users.first(where: { $0.id == currentUserID }) else { return nil }
        
        self.users = users
        self.followers = followers
        self.currentUserID = currentUserID
        self.currentUserData = currentUserData
    }


    /// Возвращает текущего пользователя.

    func currentUser() -> UserProtocol {
        return User(
            id: currentUserID,
            username: currentUserData.username,
            fullName: currentUserData.fullName,
            avatarURL: currentUserData.avatarURL,
            currentUserFollowsThisUser: (usersFollowedByUser(with: currentUserID) != nil), // он подписан
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
        var correctUser = currentUser()
        for user in users {
            if user.id == userID {
                correctUser = user as! UserProtocol
            }
        }
        return correctUser
    }
    //-------------------
    
    /// Возвращает всех пользователей, содержащих переданную строку.
    ///
    /// - Parameter searchString: Строка для поиска.
    /// - Returns: Массив пользователей. Если не нашлось ни одного пользователя, то пустой массив.
    func findUsers(by searchString: String) -> [UserProtocol] {
        var ArrayOfFindingUsers = [UserProtocol]()
        var lookingUser: UserProtocol
        for user in users {
            if user.username == searchString {
                lookingUser = user as! UserProtocol
                ArrayOfFindingUsers.append(lookingUser)
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
        var arrayOfLookingUsers = [UserProtocol]()
        for follower in followers {
            for user in users {
                if follower.1 == user.id {
                    let followUser = user
                    print(followUser)
                    arrayOfLookingUsers.append(followUser as! UserProtocol)
                } else if arrayOfLookingUsers.isEmpty {
                    return arrayOfLookingUsers
                } else if user.id != follower.1 {
                    return nil
                }
            }
        }
        return arrayOfLookingUsers
    }
    
    
    /// Возвращает все подписки пользователя.
    ///
    /// - Parameter userID: ID пользователя подписки которого нужно вернуть.
    /// - Returns: Массив пользователей.
    /// Пустой массив если он ни на кого не подписан.
    /// nil если такого пользователя нет.
    
    
    //он подписчик
    func usersFollowedByUser(with userID: GenericIdentifier<UserProtocol>) -> [UserProtocol]? {
        var arrayOfLookingUsers = [UserProtocol]()
        for follower in followers {
            for user in users {
                if user.id == follower.1 {
                    let followUser = user as? UserProtocol
                    arrayOfLookingUsers.append(followUser!)
                } else if arrayOfLookingUsers.isEmpty {
                    return arrayOfLookingUsers
                } else if user.id != follower.1 {
                    return nil
                }
            }
        }
        return arrayOfLookingUsers
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
        var array = [PostInitialData]()
        for post in posts {
            if postID == post.id {
                array.append(post)

            } else if postID != post.id {
                return nil
            }
        }
        var correctPost = array[0]
        for value in array {
            if value.id == postID {
                correctPost = value
            }
        }

        let correctPostInPostProtocol = correctPost as! PostProtocol
        return correctPostInPostProtocol
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
                let postProtocolPost = post as! PostProtocol
                arrayOfPosts.append(postProtocolPost)
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
        for post in posts {
            let string = post.author as! String
            if searchString == string {
                let lookingPost = post as! PostProtocol
                arrayOfThePosts.append(lookingPost)
                return arrayOfThePosts
            } else if arrayOfThePosts.isEmpty {
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
        var arrayOfUsers = [GenericIdentifier<UserProtocol>]()
        for like in likes {
        let userPost = like.1
            if userPost == postID {
                if userPost != nil {
                    let correct = userPost as! GenericIdentifier<UserProtocol>
                    arrayOfUsers.append(correct)
                    return arrayOfUsers
                }
            } else if arrayOfUsers.isEmpty {
                return arrayOfUsers
        }
    }
        return arrayOfUsers
}
}


let userStorageClass = UserStorageClass.self
let postsStorageClass = PostsStorageClass.self

let checker = Checker(usersStorageClass: userStorageClass,
                      postsStorageClass: postsStorageClass)
checker.run()
