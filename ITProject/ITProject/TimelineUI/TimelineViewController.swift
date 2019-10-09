//
//  TimelineViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/9/20.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController
{
	var scrollView: UIScrollView!
	var timeline: TimelineView!
    var timeFrames: [TimelineField] = []
    public var familyUID: String!


	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		setupScrollView()

        loadTimeFrames()
       
		view.sendSubviewToBack(self.scrollView)
	}
    
    /// get timeline data from db
    private func loadTimeFrames(){
//        self.timeFrames = [
//            TimelineField(date: "January 1", content: "New Year's Day", image: UIImage(named: "tempProfileImage")),
//            TimelineField(date: "February 14", content: "The month of love!", image: UIImage(named: "heartIcon")),
//            TimelineField(date: "March", content: "Comes like a lion, leaves like a lamb", image: nil),
//            TimelineField(date: "April 1", content: "Dumb stupid pranks.", image: UIImage(named: "eye")),
//            TimelineField(date: "No image?", content: "That's right. No image is necessary!"),
//            TimelineField(date: "Long text", content: "This control can stretch. It doesn't matter how long or short the text is, or how many times you wiggle your nose and make a wish. The control always fits the content, and even extends a while at the end so the scroll view it is put into, even when pulled pretty far down, does not show the end of the scroll view."),
//            TimelineField(date: "Long text", content: "This control can stretch. It doesn't matter how long or short the text is, or how many times you wiggle your nose and make a wish. The control always fits the content, and even extends a while at the end so the scroll view it is put into, even when pulled pretty far down, does not show the end of the scroll view."),
//            TimelineField(date: "That's it!"),
//        ]
        
        //bug here: it shows nothing:(
        print("FAMILY UID IS AT LOADTIMEFRAMES: ",self.familyUID)
        Util.ShowActivityIndicator()
        CacheHandler.getInstance().getAlbumInfo(familyID: DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.FAMILY_COLLECTION_NAME, documentUID: self.familyUID)) { (data, error) in
            if let error = error{
                print("error at loadTimeFrames:::", error)
            }else{
                print("RUNS HERE")
                data.forEach { (data) in
                    let (albumName, albumDetail)  = data
                    //PARSE DATE TO STRING:
                    
                    let createdDateTmp : Date = albumDetail[AlbumDBController.ALBUM_DOCUMENT_FIELD_CREATED_DATE] as! Date
                    let str =  createdDateTmp.description
                    let dateTimeComponents : [String] = (str.components(separatedBy: " "))
                    let dateSeparator : String = "-"
                    let timeSeparator : String = ":"
                    
                    let yearMonthDate : [String] = dateTimeComponents[0].components(separatedBy: dateSeparator)
                    let time : [String] = dateTimeComponents[1].components(separatedBy: timeSeparator)
                    print("dateTimeComponents",  dateTimeComponents)
                    print("time:", time)
                    let createdDate = yearMonthDate[2] + dateSeparator +  yearMonthDate[1] + dateSeparator + yearMonthDate[0] + " at " + time[0] + timeSeparator + time[1]
                    
                    let content :String = albumDetail[AlbumDBController.ALBUM_DOCUMENT_FIELD_OWNER] as! String + " created " + albumName
                    self.timeFrames
                                    .append(
                                              TimelineField(
                                                          date: createdDate ,
                                                          content:content
                                                           )
                                                   )
                                              
                  
                }
                
                self.timeline = TimelineView(timeFrames: self.timeFrames)
                self.setupTimelineView()


                print("TIMEFRAME IS", self.timeFrames)
                self.reloadInputViews()

                Util.DismissActivityIndicator()

               
               
                
            }
            
            
        }
    }
    
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
    
    private func setupTimelineField(){
        
    }
}
