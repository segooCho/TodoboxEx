//
//  TaskListViewController.swift
//  Todobox
//
//  Created by admin on 2017. 2. 13..
//  Copyright © 2017년 admin. All rights reserved.
//

import UIKit
import Alamofire

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
            self.saveTaskAll()
        }
    }
    
     var taskList: [TaskList] = []
    
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(taskDidAdd), name: .taskDidAdd, object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.doneButton.target = self
        self.doneButton.action = #selector(doneButtonDidTap)

        
        //TODO :: 서버에서 목록 가져오기
        let urlString = "http://127.0.0.1:3000/"
        
        Alamofire.request(urlString).responseJSON { response in
            switch response.result {
            case .success(let value) :
                guard let json = value as? [[String: Any]] else {break}
                let tempTaskList = [TaskList](JSONArray: json) ?? [] //?? : 앞에 있는 연산자가 오류이면 []를 실행하라
                self.taskList.append(contentsOf: tempTaskList)
                self.tableView.reloadData()
            case .failure(let error) :
                print("요청 실패 \(error)")
                
            }
        }
        
        
        /*
        Alamofire.request("https://api.graygram.com/feed").responseJSON { response in
            switch response.result {
            case .success(let value) :
                guard let json = value as? [String: Any] else {break}
                if let data = json["data"] as? [[String: Any]] {
                    let tempTaskList = [TaskList](JSONArray: data) ?? [] //?? : 앞에 있는 연산자가 오류이면 []를 실행하라
                    self.taskList.append(contentsOf: tempTaskList)
                    self.tableView.reloadData()
                }
                
            case .failure(let error) :
                print("요청 실패 \(error)")
                
            }
        }
        */
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //self.performSegueWithIdentifier("nextView", sender: self)
        if segue.identifier == "taskCell" {
            print("taskCell")
        } else {
            print("addButton")
        }
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        print("prepareForSegue")
    }
    
    //TODO :: TaskEditViewController 저장 시
    func taskDidAdd(_ notification: Notification ) {
        guard let task = notification.userInfo?["task"] as? Task else { return }
        self.tasks.append(task)
        self.tableView.reloadData()
        self.saveTaskAll();
    }
    
    func saveTaskAll() {
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
    
    @IBAction func editButtonDidTap() {
        guard !self.tasks.isEmpty else { return }
        
        self.navigationItem.leftBarButtonItem = self.doneButton
        self.tableView.setEditing(true, animated: true)
    }

    func doneButtonDidTap() {
        self.navigationItem.leftBarButtonItem = self.editButton
        self.tableView.setEditing(false, animated: true)
    }

}


extension TaskListViewController: UITableViewDataSource{
    //tableView Row Count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return tasks.count
        return self.taskList.count
    }
        
    //tableView Row Data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        let task = self.taskList[indexPath.row]
        cell.textLabel?.text = "to. " + task.nickName + " (" + task.phoneNo + ")"
        cell.detailTextLabel?.text = task.message
        cell.accessoryType = .disclosureIndicator
        /*
        if task.isDone {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        */
        return cell
    }
}


extension TaskListViewController: UITableViewDelegate{
    //Task 선택
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath)가 선택!")
        var task = self.taskList[indexPath.row]
        //task.isDone = !task.isDone
        self.taskList[indexPath.row] = task
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    //삭제
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        self.tasks.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        self.saveTaskAll();
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
