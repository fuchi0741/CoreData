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
    // CREATE
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
    
    //もう一度解読する必要あり
    func updata(currentStudent student: Student, withName name: String, forLesson lesson: String) {
        //レッスンが変更ない場合
        if student.lesson?.type == lesson {
            let lesson = student.lesson
            let studentList = Array(lesson?.students?.mutableCopy() as! NSMutableSet) as! [Student]
            if let index = studentList.index(where: { $0 == student }){
                studentList[index].name = name
                lesson?.students = NSSet(array: studentList)
            }
        }
        else {
            if let lesson = lessonExists(LessonType(rawValue: lesson)!){
                lesson.removeFromStudents(student)
                student.name = name
                register(student, fot: lesson)
            }
        }
        save()
    }
    
    // READ
    func getAllStudents() -> [Student]? { //?を記述することでnilを返すことを許容している
        //lessonごとにsortできるようにする
        let sortByLesson = NSSortDescriptor(key: "lesson.type", ascending: true)//sortにする対象を記述して初期化をする
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptions = [sortByLesson,sortByName]
    
        let request: NSFetchRequest<Student> = Student.fetchRequest()//fetchをリクエストする対象を初期化する
        request.sortDescriptors = sortDescriptions //fetchをリクエストする対象をsortする
        
        do {
            students =  try moc.fetch(request)//対象のリクエストをfetchしてstudentsに格納する
            return students
        }
        catch let error as NSError {
            print("Error fetch students \(error.localizedDescription)")
            return nil
        }
    }
    
    //Delete
    func delete(student: Student) {
        let lesson = student.lesson
        students = students.filter({ $0 != student})
        lesson?.removeFromStudents(student)
        moc.delete(student)
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
