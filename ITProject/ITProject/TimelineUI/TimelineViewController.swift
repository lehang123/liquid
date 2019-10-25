//
//  TimelineViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/9/20.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit
import Firebase


class TimelineViewController: UIViewController
{
    // MARK:- Properties
    public var familyUID: String!
   
	private var scrollView: UIScrollView!
	private var timeline: TimelineView!
    private var timeFrames: [TimelineField] = []
    
    // MARK: - Methods
	override func viewDidLoad() {
		super.viewDidLoad()
		setupScrollView()
        loadTimeFrames()
	}
    
    /// get timeline data from db
    private func loadTimeFrames(){

        AlbumDBController.getInstance().getAlbumInfo(familyID: DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.FAMILY_COLLECTION_NAME, documentUID: self.familyUID)) { (data, error) in
            if let error = error{
                print("error at loadTimeFrames:::", error)
            }else{
                //using DispatchGroup to wait for images to download:
                let group = DispatchGroup()
                //print("RUNS HERE")
                data.forEach { (data) in
                    let (albumName, albumDetail)  = data
                    //parse date to string:
                    let createdDateTmp : Date = albumDetail[AlbumDBController.ALBUM_DOCUMENT_FIELD_CREATED_DATE] as! Date
                    let createdDate : String = createdDateTmp.DateToStringWithTimes()
                    
                    //enter async :
                    
                    group.enter()

                    
                        Util.GetImageData(
                            imageUID: (albumDetail[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL] as! String),
                            UIDExtension: (albumDetail[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION] as! String),
                            completion: { (data) in
                                group.enter()
                                DBController
                                    .getInstance()
                                    .getDocumentFromCollection(
                                    collectionName: RegisterDBController.USER_COLLECTION_NAME,
                                    documentUID:  albumDetail[AlbumDBController.ALBUM_DOCUMENT_FIELD_OWNER] as! String)
                                    { (doc, e) in
                                    if let error  = e {
                                        print("error at getting timeline", error)
                                    }
                                    else{
                                        //find album creator:
                                        let content :String =  doc?.get(RegisterDBController.USER_DOCUMENT_FIELD_NAME) as! String + " created " + albumName
                                        
                                        //pass data to UI:
                                        self.timeFrames
                                        .append(
                                            TimelineField(
                                                date: createdDate ,
                                                content: content,
                                                image: UIImage(data: data!)) )
                                        group.leave()
                                    }
                                }
                                
                                
                            
                            //so, wait until this completion finished
                            group.leave()
                        })

                }
                
                //after all images downloaded, continue loading UI:
                group.notify(queue: .main) {
                    //continue loading UI:
                    self.timeline = TimelineView(timeFrames: self.timeFrames)
                        
                    self.setupTimelineView()
                    self.view.sendSubviewToBack(self.scrollView)
                }
            }
            
        }
    }
    
    /// Set up Scroll View
    private func setupScrollView(){
        self.scrollView = UIScrollView(frame: view.bounds)
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.scrollView)

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: scrollView!, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: scrollView!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 29),
            NSLayoutConstraint(item: scrollView!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: scrollView!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0),
        ])
    }
    
    /// Set up Timeline View
    private func setupTimelineView(){
        timeline.timelinePointRadius = 16
        scrollView.addSubview(timeline)
        scrollView.addConstraints([
            NSLayoutConstraint(item: timeline!, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: timeline!, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: timeline!, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: timeline!, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: timeline!, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1.0, constant: 0),
        ])
    }
    
}

