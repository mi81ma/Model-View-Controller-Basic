//
//  ViewController.swift
//  Model View Controller Basic
//
//  Created by masato on 16/10/2018.
//  Copyright © 2018 masato. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}


// ************** Model from here *************************

/*
 Model - Task

 • text タスクの内容
 • deadline タスクの締め切り時間
 • text と deadline を引数に持つイニシャライザ • dictionary を引数に持つイニシャライザ
 */

class Task {

    let text: String
    let deadline: Date


    /*
     This Initialize Method:
    get text & deadline from variable
    and generate Task
     */

    init(text: String, deadline: Date) {
        self.text = text
        self.deadline = deadline
    }


    /*
     This Initialize Method:
     generate from UserDefault's dictionary
     */

    init(from dictionary: [String: Any]) {
        self.text = dictionary["text"] as! String
        self.deadline = dictionary["deadline"] as! Date
    }

}


/*

 Model - TaskDateSource

 データの振る舞いやそれに関するロジックを保持する

 • Task を UserDefaults に保存する。
 • 保存したTaskを取り出し、Array として管理する (tableView で表示させる)

 */

class TaskDataSource: NSObject {
    private var tasks = [Task]()

    func loadData() {
        let userDefaults = UserDefaults.standard
        let taskDictionaries = userDefaults.object(forKey: "tasks") as? [[String: Any]]
        guard let t = taskDictionaries else { return }

        for dic in t {
            let task = Task(from: dic)
            tasks.append(task)
        }
    }

// "save" method save "Task" in "UserDefaults"
    func save(task: Task) {
        tasks.append(task)

        var taskDictionaries = [[String: Any]]()
        for t in tasks {
            let taskDictionary: [String: Any] = ["text": t.text, "deadline": t.deadline]
            taskDictionaries.append(taskDictionary)
        }

        let userDefaults = UserDefaults.standard
        userDefaults.set(taskDictionaries, forKey: "tasks")
        userDefaults.synchronize()
    }


    // count how many Task is. "count" method is be using to count how many Cells in UItableView
    func count() -> Int {
        return tasks.count
    }

    /*
     Return digignated Task for "index No."
     "index" is conected to "IndexPath.row"
    */
    func data(at index: Int) -> Task? {
        if tasks.count > index {
            return tasks[index]
        }
        return nil
    }
}

/*

 View

 */


class taskListCell: UITableViewCell {

    private var taskLabel: UILabel!
    private var deadlineLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        taskLabel = UILabel()
        taskLabel.textColor = UIColor.black
        taskLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(taskLabel)

        deadlineLabel = UILabel()
        deadlineLabel.textColor = UIColor.black
        deadlineLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(deadlineLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hasnot been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        taskLabel.frame = CGRect(x: 15.0, y: 15.0, width: contentView.frame.width - (15.0 * 2), height: 15)

        deadlineLabel.frame = CGRect(x: taskLabel.frame.origin.x, y: taskLabel.frame.maxY + 8.0, width: taskLabel.frame.width, height: 15.0)
    }

    var task: Task? {
        didSet {
            guard let t = task else {return}
            taskLabel.text = t.text
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"

            deadlineLabel.text = formatter.string(from: t.deadline)
        }
    }
}

/*

 Controller

*/

class TasklistViewController: UIViewController {

    var dataSource: TaskDataSource!
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = TaskDataSource()

        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self as! UITableViewDelegate
        tableView.dataSource = self as! UITableViewDataSource
        tableView.register(taskListCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)

        let barButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(barButtonTapped(:))
            navigationItem.rightBarButtonItem = barButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.loadData()
        tableView.reloadData()
    }

    func barButtonTapped(_ sender: UIBarButtonItem) {

        let controller = CreateTaskViewController()
        present(controller, animated: true, completion: nil)
    }
}

extension TasklistViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! taskListCell

        let task = dataSource.data(at: IndexPath.row)

        cell.task = task
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }

}



class CreateTaskViewController: UIViewController {
    fileprivate var createTaskView: CreateTaskViewController
    fileprivate var dataSource: TaskDataSource!
    fileprivate var taskText: String?
    fileprivate var taskDeadline: Date?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        /*
         CreateTaskView を生成し、デリゲートに self をセットしている。 */
        createTaskView = createTaskView; createTaskView.delegate = self; view.addSubview(createTaskView)
        /*
         TaskDataSource を生成。
         */
        dataSource = TaskDataSource()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /*
         CreateTaskView のレイアウトを決めている。
         */
        createTaskView.frame = CGRect(x: view.safeAreaInsets.left,
                                      y: view.safeAreaInsets.top,
                                      width: view.frame.size.width - view.safeAreaInsets.left, -view.safeAreaInsets.right,
                                      height: view.frame.size.height - view.safeAreaInsets.bottom)
    }

    /*
     保存が成功した時のアラート。 保存が成功したら、アラートを出し、前の画面に戻っている。 */
    fileprivate func showSaveAlert() {
        let alertController = UIAlertController(title: "保存しました", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { (action) in
            _ = self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
        }

    /*
     タスクが未入力の時のアラート。 タスクが未入力の時に保存して欲しくない。
     */


    fileprivate func showMissingTaskTextAlert() {
        let alertController = UIAlertController(title: "タスクを入力してください", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    /*
     締切日が未入力の時のアラート。 締切日が未入力の時に保存して欲しくない。
     */
    fileprivate func showMissingTaskDeadlineAlert() {
        let alertController = UIAlertController(title: "締切日を入力してください", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)

    }
}



// CreateTaskViewDelegate メソッド
extension CreateTaskViewController: CreateTaskViewDelegate {
    func createView(taskEditting view: CreateTaskView, text: String) {
        /*
         タスク内容を入力している時に呼ばれるデリゲードメソッド。 CreateTaskView からタスク内容を受け取り、taskText に代入している。 */
        taskText = text
    }
    func createView(deadlineEditting view: CreateTaskView, deadline: Date) {
        /*
         締切日時を入力している時に呼ばれるデリゲードメソッド。
         CreateTaskView から締切日時を受け取り、taskDeadline に代入している。 */
        taskDeadline = deadline
    }
    func createView(saveButtonDidTap view: CreateTaskView) {
        /*
         保存ボタンが押された時に呼ばれるデリゲードメソッド。
         taskText が nil だった場合 showMissingTaskTextAlert() を呼び、
         taskDeadline が nil だった場合 showMissingTaskDeadlineAlert() を呼んでいる。
         どちらも nil でなかった場合に、taskText, taskDeadline から Task を生成し、 dataSource.save(task: task) を呼んで、task を保存している。
         保存完了後 showSaveAlert() を呼んでいる。
         */
        guard let taskText = taskText else {
            showMissingTaskTextAlert()
            return
        }

        guard let taskDeadline = taskDeadline else {
            showMissingTaskDeadlineAlert()
            return
        }

        let task = Task(text: taskText, deadline: taskDeadline)
        dataSource.save(task: task)

        showSaveAlert()
    }
}


/*
 CreateTaskViewController へユーザーインタラクションを伝達するための Protocol です。
 */
protocol CreateTaskViewDelegate: class {
    func createView(taskEditting view: CreateTaskView, text: String)
    func createView(deadlineEditting view: CreateTaskView, deadline: Date)
    func createView(saveButtonDidTap view: CreateTaskView)
}


class CreateTaskView: UIView {

    private var taskTextField: UITextField! // タスク内容を入力する UITextField
    private var datePicker: UIDatePicker! // 締切時間を表示する UIPickerView
    private var deadlineTextField: UITextField! // 締切時間を入力する UITextField
    private var saveButton: UIButton! // 保存ボタン

    weak var delegate: CreateTaskViewDelegate? // デリゲート


    required override init(frame: CGRect) {

    super.init(frame: frame)

//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    taskTextField = UITextField()
    taskTextField.delegate = self
    taskTextField.tag = 0
    taskTextField.placeholder = "予定を入れてください"
    addSubview(taskTextField)

    deadlineTextField = UITextField()
    deadlineTextField.tag = 1
    deadlineTextField.placeholder = "期限を入れてください"
    addSubview(deadlineTextField)

    datePicker = UIDatePicker()
    datePicker.datePickerMode = .dateAndTime
    datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)),
    for: .valueChanged)

    /*
     UITextField が編集モードになった時に、キーボードではなく、
     UIDatePicker になるようにしている
     */
    deadlineTextField.inputView = datePicker

    saveButton = UIButton()
    saveButton.setTitle("保存する", for: .normal)
    saveButton.setTitleColor(UIColor.black, for: .normal)
    saveButton.layer.borderWidth = 0.5
    saveButton.layer.cornerRadius = 4.0
    saveButton.addTarget(self, action: #selector(saveButtonTapped(_:)),
    for: .touchUpInside)
    addSubview(saveButton)
}

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


@objc func saveButtonTapped(_ sender: UIButton) {
    /*
     save ボタンが押された時に呼ばれるメソッド
     押したという情報を CreateTaskViewController へ伝達している。 */

    delegate?.createView(saveButtonDidTap: self)
}


@objc func datePickerValueChanged(_ sender: UIDatePicker) {
    /*
     UIDatePicker の値が変わった時に呼ばれるメソッド。
     sender.date がユーザーが選択した締め切り日時で、DateFormatter を用いて String に変 換し、
     deadlineTextField.text に代入している。
     また、日時の情報を CreateTaskViewController へ伝達している。 */

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat  = "yyyy/MM/dd HH:mm"
    let deadlineText = dateFormatter.string(from: sender.date)
    deadlineTextField.text = deadlineText
    delegate?.createView(deadlineEditting: self, deadline: sender.date)
}


override func layoutSubviews() {
    super.layoutSubviews()
    taskTextField.frame = CGRect(x: bounds.origin.x + 30,
                                 y: bounds.origin.y + 30,
                                 width: bounds.size.width - 60,
                                 height: 50)

    deadlineTextField.frame = CGRect(x: taskTextField.frame.origin.x,
                                     y: taskTextField.frame.maxY + 30,
                                     width: taskTextField.frame.size.width,
                                     height: taskTextField.frame.size.height)
    let saveButtonSize =  CGSize(width: 100, height: 50)
    saveButton.frame = CGRect(x: (bounds.size.width - saveButtonSize.width) / 2,
                              y: deadlineTextField.frame.maxY + 20,
                              width: saveButtonSize.width,
                              height: saveButtonSize.height)
    }
}

extension CreateTaskView: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField.tag == 0 {
            /*
             textField.tag で識別している。もし tag が 0 の時、textField.text すなわち、 ユーザーが入力したタスク内容の文字を CreateTaskViewController に伝達してい
             */
            delegate?.createView(taskEditting: self, text: textField.text ?? "")
        }
        return true }
}
