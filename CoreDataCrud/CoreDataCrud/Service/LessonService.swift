//
//  Service.swift
//  CoreDataCrud
//
//  Created by 渕一真 on 2020/06/10.
//  Copyright © 2020 渕一真. All rights reserved.
//

import Foundation
import CoreData

enum LessonType: String {
    case ski, snow
}

typealias StudentHandler = (Bool, [Student]) -> ()

class LessonService {
    //管理されているオブジェクト(ManagedObject)をいじるとき使用
    private let moc: NSManagedObjectContext
    private var students = [Student]()//学生の数(ManagedObject)を保持する
    
    init(moc: NSManagedObjectContext) {
        self.moc = moc
    }
    
    //MARK: -Public
    func addStudent(name: String, for type: LessonType, completion: StudentHandler) {
        //completionは生徒をす追加したことをLessonTVCに伝えるため
        let student = Student(context: moc)
        student.name = name
        if let lesson = lessonExists(type) {
            register(student, fot: lesson)
            students.append(student)
            completion(true, students)
        }
        save()
    }
    
    //MARK: -Private
    //studentがすでにレッスンを登録しているかどうか
    private func lessonExists(_ type: LessonType) -> Lesson? {
        let request: NSFetchRequest<Lesson> = Lesson.fetchRequest()
        request.predicate = NSPredicate(format: "type = %@", type.rawValue)
        //type = %@は何かしらのフォーマットを形成している
        var lesson = Lesson(context: moc)
        do {
            let result = try moc.fetch(request)
            lesson = result.isEmpty ? addNew(lesson: type) : result.first!
        } catch let error as NSError {
            print("Error getting lesson: \(error.localizedDescription)")
        }
        return lesson
    }
    
    private func addNew(lesson type: LessonType) -> Lesson {
        let lesson = Lesson(context: moc)
        lesson.type = type.rawValue
        return lesson
    }
    
    private func register(_ student: Student, fot lesson: Lesson) {
        student.lesson = lesson
    }
    
    private func save(){
        do {
            try moc.save()
        } catch let error as NSError {
            print("Save failed: \(error.localizedDescription)")
        }
    }
}
