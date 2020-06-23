//
//  LessonTableViewController.swift
//  CoreDataCrud
//
//  Created by 渕一真 on 2020/06/09.
//  Copyright © 2020 渕一真. All rights reserved.
//

import UIKit
import CoreData

class LessonTableViewController: UITableViewController {
    
    // MARK: - Public Properties
    var moc: NSManagedObjectContext? {
        didSet {
            if let moc = moc {
                lessonService = LessonService(moc: moc)
            }
        }
    }
    
    // MARK: - Private Properties
    private var lessonService: LessonService?
    private var studentList = [Student]()
    
    @IBAction func toucheAddStudentButton(_ sender: UIBarButtonItem) {
        present(alertController(actionType: "add"), animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath)
        return cell
    }
    
    // MARK: - Private
    private func alertController(actionType: String) -> UIAlertController {
        let alertController = UIAlertController(title: "Fuchi Lesson", message: "Student Info", preferredStyle: .alert)
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = "名前"
        }
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Lesson: スキー or スノボ"
        }
        let defaultAction = UIAlertAction(title: actionType.uppercased(), style: .default) { [weak self] (action) in
            guard let studentName = alertController.textFields?[0].text, let lesson = alertController.textFields?[1].text else { return }
            if actionType.caseInsensitiveCompare("add") == .orderedSame {
                if let lessonType = LessonType(rawValue: lesson.lowercased()) {
                    self?.lessonService?.addStudent(name: studentName, for: lessonType, completion: { (success, studentss) in
                        if success {
                            self?.studentList = studentss
                        }
                    })
                }
            }
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {  (action) in
        }
        alertController.addAction(defaultAction)
        alertController.addAction(cancelAction)
        return alertController
    }
}
