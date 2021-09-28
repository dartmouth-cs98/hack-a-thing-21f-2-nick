//
//  ViewController.swift
//  noteApp
//
//  Created by Nicholas Schoeller on 9/27/21.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var table: UITableView!
    var data:[String] = []
    var fileURL:URL!
    var selectedRow:Int = -1
    var newRowText:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        table.dataSource = self
        table.delegate = self // interactivity
        
        // adding notes title at the top
        self.title = "Notes"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        
        
        // button to add a note
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        
        self.navigationItem.rightBarButtonItem = addButton
        
        // edit mode item
        self.navigationItem.leftBarButtonItem = editButtonItem
        
        
        let baseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        fileURL = baseURL.appendingPathComponent("notes.txt")
        
        load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if selectedRow == -1 {
            return
        }
        
        data[selectedRow] = newRowText
        if newRowText == "" {
            data.remove(at: selectedRow)
        }
        table.reloadData()
        
        save()
    }
    
    // adds notes
    @objc func addNote() {
        // disallow adding notes while in editing mode
        if table.isEditing {
            return
        }
        
        let name:String = ""
        data.insert(name, at: 0)
        let indexPath:IndexPath = IndexPath(row: 0, section: 0)
        table.insertRows(at: [indexPath], with: .automatic)
        
        table.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        
        
        // change to note screen
        self.performSegue(withIdentifier: "detail", sender: nil)
    }
    
    // how many rows inside the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    // set editing mode
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        table.setEditing(editing, animated: animated)
    }
    
    // used for deleting notes
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        data.remove(at: indexPath.row)
        table.deleteRows(at: [indexPath], with: .fade)
        save()
    }
    
    // handles selecting the row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "detail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailView:DetailViewController = segue.destination as! DetailViewController
        selectedRow = table.indexPathForSelectedRow!.row
        
        detailView.masterView = self
        detailView.setText(t: data[selectedRow])
        
    }
    
    // saves data and it can be accessed again later
    func save() {
        // UserDefaults.standard.set(data, forKey: "notes")
        let a = NSArray(array: data)
        do {
            try a.write(to: fileURL)
        } catch {
            print("error writing file")
        }
    }
    
    func load() {
        // if the data loads in and the type cast works, then...
        if let loadedData:[String] = NSArray(contentsOf: fileURL) as? [String] {
            data = loadedData
            table.reloadData()
        }
    }
    

}

