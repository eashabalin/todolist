//
//  ToDoTableViewController.swift
//  ToDoList
//
//  Created by Егор Шабалин on 30.04.2021.
//

import UIKit

class ToDoTableViewController: UITableViewController, ToDoCellDelegate {
    
    var todos = [ToDo]()
    
    func checkmarkTapped(sender: ToDoCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            var todo = todos[indexPath.row]
            todo.isComplete.toggle()
            todos[indexPath.row] = todo
            tableView.reloadRows(at: [indexPath], with: .automatic)
            ToDo.saveToDos(todos)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let savedTodos = ToDo.loadToDos() {
            todos = savedTodos
        } else {
            todos = ToDo.loadSampleToDos()
        }
        
        navigationItem.leftBarButtonItem = editButtonItem
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCellIdentifier", for: indexPath) as! ToDoCell
        let todo = todos[indexPath.row]
        cell.titleLabel.text = todo.title
        cell.isCompleteButton.isSelected = todo.isComplete
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            ToDo.saveToDos(todos)
        }
    }
    
    @IBAction func unwindToToDoList(segue: UIStoryboardSegue) {
        if segue.identifier == "saveUnwind" {
            let sourceViewController = segue.source as! ToDoDetailTableViewController
            let todo = sourceViewController.todo!
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: true)
                todos[selectedIndexPath.row] = todo
                tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
            } else {
                let newIndexPath = IndexPath(row: todos.count, section: 0)
                todos.append(todo)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        } else {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        }
        ToDo.saveToDos(todos)
    }
    
    @IBSegueAction func editToDo(_ coder: NSCoder, sender: Any?) -> ToDoDetailTableViewController? {
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else { return nil }
        let detailController = ToDoDetailTableViewController(coder: coder)
        detailController?.todo = todos[indexPath.row]
        return detailController
    }
    
}
