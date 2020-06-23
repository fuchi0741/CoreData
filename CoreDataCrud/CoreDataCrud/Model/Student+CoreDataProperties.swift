//
//  Student+CoreDataProperties.swift
//  CoreDataCrud
//
//  Created by 渕一真 on 2020/06/01.
//  Copyright © 2020 渕一真. All rights reserved.
//
//

import Foundation
import CoreData


extension Student {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Student> {
        return NSFetchRequest<Student>(entityName: "Student")
    }

    @NSManaged public var name: String?
    @NSManaged public var lesson: Lesson?

}
