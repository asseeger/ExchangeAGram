//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by Andreas Seeger @MBPR on 22.11.14.
//  Copyright (c) 2014 ASSeeger. All rights reserved.
//

import Foundation
import CoreData

@objc (FeedItem)

class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData
    @NSManaged var thumbnail: NSData

}
