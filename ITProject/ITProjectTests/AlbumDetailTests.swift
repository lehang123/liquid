//
//  AlbumDetailTest.swift
//  ITProjectTests
//
//  Created by Gong Lehan on 3/10/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import XCTest
@testable import ITProject

class AlbumDetailTests:XCTestCase {
    
    func testVaildAlbum(){

        let album = AlbumDetail(title: "DummyAlbum", description: "none", UID: Util.GenerateUDID(), coverImageUID: nil, coverImageExtension: nil, createdLocation: "home")
        
        let album2 = AlbumDetail(title: "DummyAlbum", description: "none", UID: "Util.GenerateUDID()", coverImageUID: nil, coverImageExtension: nil, createdLocation: "home")
        
        XCTAssertTrue(album.testVaildId())
        XCTAssertFalse(album2.testVaildId())
    }
    
    func testVaildMedia(){

        let photo = MediaDetail(title: "anything", description: "anything", UID: Util.GenerateUDID(), likes: [], comments: nil, ext: Util.EXTENSION_M4A, watch: nil, audioUID: "")
        
        let photo2 = MediaDetail(title: "anything", description: "anything", UID: "Util.GenerateUDID()", likes: [], comments: nil, ext: Util.EXTENSION_M4A, watch: nil, audioUID: "")
        
        let photo3 = MediaDetail(title: "anything", description: "anything", UID: Util.GenerateUDID(), likes: [], comments: nil, ext: "mp3", watch: nil, audioUID: "")
        
        XCTAssertTrue(photo.testVaildId())
        XCTAssertTrue(photo.vaildExtension())
        
        XCTAssertFalse(photo2.testVaildId())
        XCTAssertTrue(photo2.vaildExtension())
        
        XCTAssertTrue(photo3.testVaildId())
        XCTAssertFalse(photo3.vaildExtension())
     }
    
    
}
