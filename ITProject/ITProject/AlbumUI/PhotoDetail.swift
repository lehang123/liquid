//
//  PhotoDetail.swift
//  ITProject
//
//  Created by Gong Lehan on 6/9/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation

import UIKit


class PhotoDetail: Equatable
{
    
    public struct comment:Equatable {
        let commentID:String!
        let username:String!
        let message: String!
        
        static func == (lhs: comment, rhs: comment) -> Bool {
            return lhs.commentID == rhs.commentID
        }
    }
    
    /* filename :  UID.zip or UID.jpg */
    public let UID:String!;
    public let ext :String!;
    private var watch : Int;
    
    public func getUID()->String{
        return self.UID
    }
    
    
    /* photo's title */
    private var title:String!;
    
    public func getTitle()->String{
        return self.title
    }
    
    public func changeTitle(to: String!){
        self.title = to
    }
    
    /* photo's description */
    private var description:String!;
    
    public func getDescription()->String!{
        return self.description
    }
    
    public func changeDescription(to: String!){
        self.description = to
    }
    
    /* photo's number of likes */
    private var likes:Int!
    
    public func getLikes()->Int!{
        return self.likes
    }
    
    public func upLikes() {
        self.likes += 1
    }
    
    public func DownLikes() {
        self.likes -= 1
    }
    
    /* photo's comment */
    private var comments:[comment]!
    
    public func getComments()-> [comment]! {
        return comments;
        
    }
    public func getWatch()-> Int {
        return watch;
    }
    
    public func addComments(comment : comment) {
        comments.append(comment)
    }
    
    public func deleteComments(comment : comment) {
        comments = comments.filter {$0 != comment}
    }
    
    
    static func == (lhs: PhotoDetail, rhs: PhotoDetail) -> Bool {
        return lhs.UID == rhs.UID
    }
    
    init(title: String!, description: String!,
         UID : String!, likes: Int!, comments: [comment]!, ext: String!, watch : Int)
    {
        self.UID = UID
        self.title = title;
        self.description = description;
        self.likes = likes
        self.comments = comments
        self.ext = ext
        self.watch = watch
    }
}
