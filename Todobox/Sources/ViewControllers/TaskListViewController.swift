//
//  TaskListViewController.swift
//  Todobox
//
//  Created by admin on 2017. 2. 13..
//  Copyright © 2017년 admin. All rights reserved.
//

import UIKit

let TodoboxTasksUserDefaultsKey = "TodoboxTasksUserDefaultsKey"

class TaskListViewController: UIViewController {
    
    /*
    var tasks: [Task] = [
        Task(title:"청소"),
        Task(title:"빨래"),
        Task(title:"설거지"),
    ]
    */
    
    var tasks: [Task] = [] {
        didSet{
            self.fSaveAll()
        }
    }
    
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    
    let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    
    deinit {
        //NotificationCenter에 등록된 옵저버의 타겟 객체가 소멸
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //NotificationCenter에 등록
        NotificationCenter.default.addObserver(self, selector: #selector(fTaskDidAdd), name: .taskDidAdd, object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.doneButton.target = self
        self.doneButton.action = #selector(fDoneButtonDidTap)
        
        if let dicts = UserDefaults.standard.array(forKey: TodoboxTasksUserDefaultsKey) as? [[String: Any]] {
            self.tasks = dicts.flatMap { (disc: [String: Any]) -> Task? in
                if let title = disc["title"] as? String, let detail = disc["detail"] as? String, let isDone = disc["isDone"] as? Bool {
                    return Task(title: title, detail: detail, isDone: isDone)
                } else {
                    return nil
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func fTaskDidAdd(_ notification: Notification ) {
        guard let task = notification.userInfo?["task"] as? Task else { return }
        self.tasks.append(task)
        self.tableView.reloadData()
        self.fSaveAll();
    }
    
    func fSaveAll() {
        let dicts:[[String: Any]] = self.tasks.map {
            (task: Task) -> [String: Any] in
            return [
                "title": task.title,
                "detail": task.detail,
                "isDone": task.isDone,
                ]
        }
        
        UserDefaults.standard.set(dicts, forKey: TodoboxTasksUserDefaultsKey)
        //로컬 파일로 저장
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func fEditButtonDidTap() {
        guard !self.tasks.isEmpty else {
            return
        }
        
        self.navigationItem.leftBarButtonItem = self.doneButton
        self.tableView.setEditing(true, animated: true)
    }

    func fDoneButtonDidTap() {
        self.navigationItem.leftBarButtonItem = self.editButton
        self.tableView.setEditing(false, animated: true)
    }

}


extension TaskListViewController: UITableViewDataSource{
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        let task = self.tasks[indexPath.row]
        cell.textLabel?.text = task.title
        cell.detailTextLabel?.text = task.detail
        
        if task.isDone {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
        
}


extension TaskListViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("\(indexPath)가 선택!")
        var task = self.tasks[indexPath.row]
        task.isDone = !task.isDone
        self.tasks[indexPath.row] = task
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    //삭제
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        self.tasks.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        self.fSaveAll();
    }
    
    //위치 이동
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    //위치 이동
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var tasks = self.tasks
        
        let removeTaks = tasks.remove(at: sourceIndexPath.row)
        tasks.insert(removeTaks, at: destinationIndexPath.row)
        
        self.tasks = tasks
    }
}
