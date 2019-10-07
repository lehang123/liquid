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
        
        XCTAssertTrue(album.testValidId())
        XCTAssertFalse(album2.testValidId())
    }
    
    func testVaildMedia(){

        let photo = MediaDetail(title: "anything", description: "anything", UID: Util.GenerateUDID(), likes: [], comments: nil, ext: Util.EXTENSION_M4A, watch: nil, audioUID: "")
        
        let photo2 = MediaDetail(title: "anything", description: "anything", UID: "Util.GenerateUDID()", likes: [], comments: nil, ext: Util.EXTENSION_M4A, watch: nil, audioUID: "")
        
        let photo3 = MediaDetail(title: "anything", description: "anything", UID: Util.GenerateUDID(), likes: [], comments: nil, ext: "mp3", watch: nil, audioUID: "")
        
        XCTAssertTrue(photo.testValidId())
        XCTAssertTrue(photo.validExtension())
        
        XCTAssertFalse(photo2.testValidId())
        XCTAssertTrue(photo2.validExtension())
        
        XCTAssertTrue(photo3.testValidId())
        XCTAssertFalse(photo3.validExtension())
     }
    
    
}
