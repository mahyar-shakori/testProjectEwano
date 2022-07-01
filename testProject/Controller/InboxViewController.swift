//
//  ViewController.swift
//  testProject
//
//  Created by MahyR Sh on 6/27/22.
//

import UIKit
import Alamofire
import NVActivityIndicatorView

class InboxViewController: UIViewController {
    
    @IBOutlet weak var publicButton: UIButton!
    @IBOutlet weak var savedButton: UIButton!
    @IBOutlet weak var publicLinePager: UIView!
    @IBOutlet weak var savedLinePager: UIView!
    @IBOutlet weak var noFilterView: UIView!
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var messagesCountView: UIView!
    @IBOutlet weak var messagesCountLabel: UILabel!
    
    var messagesArray = [Messages]()
    var filteredArray = [Messages]()
    var activityIndicator: NVActivityIndicatorView!
    var savedFlag: Bool = true
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewSetup()
        activityIndicatorSetup()
        emptyView()
        messagesTableView.reloadData()
        fetchData()
    }
    
    func viewSetup(){
        
        messagesCountView.layer.cornerRadius = messagesCountView.bounds.height / 2
        savedButton.tintColor = UIColor.black.withAlphaComponent(0.5)
        messagesCountView.isHidden = true
        savedLinePager.isHidden = true
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        self.view.addGestureRecognizer(longPressRecognizer)
    }
    
    func activityIndicatorSetup(){
        
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)-200, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .ballPulse, color: UIColor.black)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func emptyView(){
        
        if self.filteredArray.count == 0 {
            self.noFilterView.isHidden = false
        } else {
            self.noFilterView.isHidden = true
        }
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizer.State.began {
            
            let touchPoint = sender.location(in: self.messagesTableView)
            if let indexPath = messagesTableView.indexPathForRow(at: touchPoint) {
                
                let alert = UIAlertController(title: "Alert", message: "Do you want to delete this item?", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Yes", style: .default) { (action) in
                    self.messagesArray.removeAll { item in
                        item.id == self.filteredArray[indexPath.row].id
                    }
                    
                    self.filteredArray.remove(at: indexPath.row)
                    self.messagesTableView.deleteRows(at: [indexPath], with: .right)
                    self.messagesCountLabel.text = String(self.filteredArray.count)
                    self.emptyView()
                }
                
                let actionDelete = UIAlertAction(title: "No", style: .default) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }
                
                alert.addAction(action)
                alert.addAction(actionDelete)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func fetchData(){
        
        AF.request(URL(string:"https://run.mocky.io/v3/729e846c-80db-4c52-8765-9a762078bc82")!, method: .get).response { [self] response in
            
            self.activityIndicator.stopAnimating()
            
            switch response.result {
                
            case .success(let data) :
                guard data != nil else {
                    return
                }
                
                let json = try? JSONDecoder.init().decode(MessagesJson.self, from: data!)
                
                messagesArray = json?.messages ?? []
                filterMessages()
                messagesCountLabel.text = String(filteredArray.count)
                messagesCountView.isHidden = false
                noFilterView.isHidden = true
                messagesTableView.reloadData()
                
            case .failure(_) :
                print("Json Error")
                break
            }
        }
    }
    
    func filterMessages() {
        
        let sortedMessages = messagesArray.sorted(by: { $0.id! > $1.id!}).sorted(by: { $0.unread!.value > $1.unread!.value })
        filteredArray = sortedMessages.filter({ Message in
            Message.saved != savedFlag
        })
        messagesTableView.reloadData()
        self.emptyView()
    }
    
    
    @IBAction func publicButtonTapped(_ sender: Any) {
        
        savedFlag = true
        filterMessages()
        savedLinePager.isHidden = true
        publicLinePager.isHidden = false
        savedButton.tintColor = UIColor.black.withAlphaComponent(0.5)
        messagesCountView.backgroundColor = UIColor.init(red: 238/255, green: 106/255, blue: 106/255, alpha: 1.0)
        publicButton.tintColor = UIColor.black
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        savedFlag = false
        filterMessages()
        publicLinePager.isHidden = true
        savedLinePager.isHidden = false
        publicButton.tintColor = UIColor.black.withAlphaComponent(0.5)
        messagesCountView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        savedButton.tintColor = UIColor.black
    }
}

extension InboxViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = messagesTableView.dequeueReusableCell(withIdentifier: "messagesCell", for: indexPath) as? MessagesTableViewCell
        let unread = filteredArray[indexPath.row].unread
        
        cell?.messageImage.image = nil
        
        if unread == false {
            cell?.cellView.backgroundColor = UIColor.white
        } else {
            cell?.cellView.backgroundColor = UIColor.init(red: 240/255, green: 243/255, blue: 246/255, alpha: 1.0)
        }
        
        let title = filteredArray[indexPath.row].title
        cell?.titleLabel.text = title
        let description = filteredArray[indexPath.row].description
        cell?.descriptionWithOutImageLabel.text = description
        let image = filteredArray[indexPath.row].image
        cell?.messageImage.downloaded(from: image ?? "")
        
        if image == nil {
            cell?.descriptionWithImageLabel.isHidden = true
            cell?.descriptionWithOutImageLabel.isHidden = false
            let description = filteredArray[indexPath.row].description
            cell?.descriptionWithOutImageLabel.text = description
        } else {
            cell?.descriptionWithImageLabel.isHidden = false
            cell?.descriptionWithOutImageLabel.isHidden = true
            let description = filteredArray[indexPath.row].description
            cell?.descriptionWithImageLabel.text = description
        }
        
        cell?.shareMessagesButton.tag = indexPath.row
        cell?.shareMessagesButton.addTarget(self, action: #selector(shareMessagesButtonTapped), for: .touchUpInside)
        
        cell?.saveMessagesButton.tag = indexPath.row
        cell?.saveMessagesButton.addTarget(self, action: #selector(saveMessagesButtonTapped), for: .touchUpInside)
        
        cell?.expandMessagesButton.tag = indexPath.row
        cell?.delegate = self
        
        if (selectedIndex == indexPath.row) {
            cell?.descriptionWithOutImageLabel.numberOfLines = 0
            cell?.descriptionWithImageLabel.numberOfLines = 0
            cell?.descriptionWithOutImageLabel.attributedText = cell?.descriptionWithOutImageLabel.justifyLabel(str: (cell?.descriptionWithOutImageLabel.text!)!)
            cell?.descriptionWithImageLabel.attributedText = cell?.descriptionWithImageLabel.justifyLabel(str: (cell?.descriptionWithImageLabel.text!)!)
            cell?.expandMessagesButton.setImage(UIImage(named: "UnExpandMessage"), for: .normal)
        } else {
            cell?.descriptionWithOutImageLabel.numberOfLines = 1
            cell?.descriptionWithImageLabel.numberOfLines = 1
            cell?.expandMessagesButton.setImage(UIImage(named: "ExpandMessage"), for: .normal)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.alpha = 0
        let transform = CATransform3DTranslate(CATransform3DIdentity, -5, 20, 0)
        cell.layer.transform = transform
        
        UIView.animate(withDuration: 1) {
            cell.alpha = 1
            cell.layer.transform = CATransform3DIdentity
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (selectedIndex == indexPath.row){
            return 370
        } else {
            return 183
        }
    }
    
    @objc func shareMessagesButtonTapped(_ sender: UIButton) {
        
        let activityVC = UIActivityViewController(activityItems: [filteredArray[sender.tag].description ?? ""], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @objc func saveMessagesButtonTapped(_ sender: UIButton) {
        
        savedFlag.toggle()
        
        let cell = self.messagesTableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? MessagesTableViewCell
        
        if savedFlag == true {
            cell?.saveMessagesButton.setImage(UIImage(named: "SavedMessages"), for: .normal)
        } else {
            cell?.saveMessagesButton.setImage(UIImage(named: "UnSavedMessages"), for: .normal)
        }
    }
}

extension InboxViewController: CutomCellDelegate {
    
    func updateTableView(row: Int) {
        
        if (selectedIndex == row){
            selectedIndex = -1
        }else {
            selectedIndex = row
        }
        let path: NSIndexPath = NSIndexPath(row: row, section: 0)
        messagesTableView.beginUpdates()
        messagesTableView.reloadRows(at: [path as IndexPath], with: UITableView.RowAnimation.automatic)
        messagesTableView.endUpdates()
    }
}
