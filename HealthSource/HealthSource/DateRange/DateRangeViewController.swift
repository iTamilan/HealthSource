//
//  DateRangeViewController.swift
//  HealthSource
//
//  Created by Tamilarasu on 10/02/18.
//  Copyright © 2018 Tamilarasu. All rights reserved.
//

import UIKit
protocol DateRangeViewControllerDelegate {
    func didChangeRange(newDateRange:DateRange)
}
fileprivate enum Row{
    case days
    case fromDate
    case toDate
    case fromDatePicker
    case toDatePicker
    case picker
    
    func title() -> String {
        switch self {
        case .days:
            return "Number of days"
        case .picker:
            return ""
        case .fromDate:
            return "From Date"
        case .toDate:
            return "To Date"
        case .fromDatePicker:
            return ""
        case .toDatePicker:
            return ""
        }
    }
}

fileprivate enum Section {
    case choose
    case custom
    func headerTitle() -> String {
        switch self {
        case .choose:
            return "Choose the Default OPTIONS"
        case .custom:
            return "Custom Range"
        }
    }
    
    func footerTitle() -> String {
        switch self {
        case .choose:
            return ""
        case .custom:
            return ""
        }
    }
    
    func rows() -> [Row] {
        switch self {
        case .choose:
            return [.days, .picker]
        case .custom:
            return [.days,.fromDate,.fromDatePicker, .toDate, .toDatePicker]
            
        }
    }
    
    
}
struct DefaultOptions {
    let days:Int
    let displayString:String
    init(days:Int, displayString:String) {
        self.days = days
        self.displayString = displayString
    }
}

class DateRangeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource , UITableViewDataSource, UITableViewDelegate{
    
    open var dateRange = DateRange(lastDays: 1)
    open var dateRangeDelegate:DateRangeViewControllerDelegate?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var optionSegmentControl: UISegmentedControl!
    
    weak var fromDatePicker:UIDatePicker?
    weak var toDatePicker:UIDatePicker?
    
    private var sections:[Section] = []
    private var defaultOptions:[DefaultOptions] = [
        DefaultOptions(days: 0, displayString: "Today"),
        DefaultOptions(days: 3, displayString: "last 3 days"),
        DefaultOptions(days: 7, displayString: "last 7 days"),
        DefaultOptions(days: 30, displayString: "last 30 days"),
        DefaultOptions(days: 30*6, displayString: "last 6 months"),
        DefaultOptions(days: 365, displayString: "last year"),
        DefaultOptions(days: -1, displayString: "All"),
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        optionChanged(self)
        self.title = "Date Range"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    @IBAction func optionChanged(_ sender: Any) {
        if optionSegmentControl.selectedSegmentIndex == 0 {
            dateRange = DateRange(lastDays: 0)
            fromDatePicker = nil
            toDatePicker = nil
        }
        refreshHeader()
        tableView.reloadData()
    }
    
    @objc open func fromDatePickerValueChanged(_ sender: UIDatePicker){
        dateRange.fromDate = sender.date
        refreshFromDatePicker()
        refreshToDatePicker()
        let indexPath0 = IndexPath(row: 0, section: 0)
        let indexPath1 = IndexPath(row: 1, section: 0)
        let indexPath3 = IndexPath(row: 3, section: 0)
        tableView.reloadRows(at: [indexPath0,indexPath1,indexPath3], with: .automatic)
        refreshHeader()
    }
    
    @objc open func toDatePickerValueChanged(_ sender: UIDatePicker){
        dateRange.toDate = sender.date
        refreshToDatePicker()
        refreshFromDatePicker()
        let indexPath0 = IndexPath(row: 0, section: 0)
        let indexPath1 = IndexPath(row: 1, section: 0)
        let indexPath3 = IndexPath(row: 3, section: 0)
        tableView.reloadRows(at: [indexPath0,indexPath1,indexPath3], with: .automatic)
        refreshHeader()
    }
    
    //MARK: TableView
    
    private func refreshHeader(){
        if optionSegmentControl.selectedSegmentIndex == 0 {
            sections = [.choose]
        }else{
            sections = [.custom]
        }
        headerLabel.text = "\(dateRange.fromDate.dateTimeString())\nto\n\(dateRange.toDate.dateTimeString())"
        tableHeaderView.updateConstraints()
        tableHeaderView.updateConstraintsIfNeeded()
        tableHeaderView.needsUpdateConstraints()
        if let delegate = dateRangeDelegate {
            delegate.didChangeRange(newDateRange: dateRange)
        }
    }

    func loadFromDatePicker(){
        fromDatePicker?.addTarget(self,
                                  action: #selector(fromDatePickerValueChanged),
                                  for: .valueChanged)
        
    }
    
    func refreshFromDatePicker(){
        fromDatePicker?.date = dateRange.fromDate
        fromDatePicker?.maximumDate = dateRange.toDate.addingTimeInterval(-120)
    }
    
    func loadToDatePicker(){
        toDatePicker?.maximumDate = Date()
        toDatePicker?.addTarget(self,
                                action: #selector(toDatePickerValueChanged),
                                for: .valueChanged)
    }
    
    func refreshToDatePicker() {
        toDatePicker?.minimumDate = dateRange.fromDate.addingTimeInterval(+120)
        toDatePicker?.date = dateRange.toDate
    }
    
    //MARK: TableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows()[indexPath.row]
        
        var cell = UITableViewCell.init(style: UITableViewCellStyle.value1, reuseIdentifier: nil)
        cell.textLabel?.text = row.title()
        

        cell.textLabel?.text = row.title()
        
        
        switch row {
        case .days:
            cell.detailTextLabel?.text = "\(dateRange.days)"
        case .fromDate:
            cell.detailTextLabel?.text = dateRange.fromDate.dateTimeString()
        case .toDate:
            cell.detailTextLabel?.text = dateRange.toDate.dateTimeString()
        case .fromDatePicker:
            let datePickerCell = tableView.dequeueReusableCell(withIdentifier: "DatePickerTableViewCell", for: indexPath) as? DatePickerTableViewCell
            if fromDatePicker == nil {
                fromDatePicker = datePickerCell?.datePickerView
                loadFromDatePicker()
            }
            refreshFromDatePicker()
            cell = datePickerCell!
        case .toDatePicker:
            let datePickerCell = tableView.dequeueReusableCell(withIdentifier: "DatePickerTableViewCell", for: indexPath) as? DatePickerTableViewCell
            if toDatePicker == nil {
                toDatePicker =  datePickerCell?.datePickerView
                loadToDatePicker()
            }
            refreshToDatePicker()
            cell = datePickerCell!
        case .picker:
            let pickerCell = tableView.dequeueReusableCell(withIdentifier: "PickerTableViewCell") as? PickerTableViewCell
            pickerCell?.pickerView?.delegate = self
            pickerCell?.pickerView?.dataSource = self
            pickerCell?.pickerView?.showsSelectionIndicator = false
            cell = pickerCell!
        }
        return cell
    }
    
    //MARK: TableViewDelegate
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].headerTitle()
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
    //MARK: UIPicker View Date source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return defaultOptions.count
    }
    
    //MARK: UIPicker View Delegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return defaultOptions[row].displayString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let defaultOption = defaultOptions[row]
        
        if defaultOption.days >= 0 {
            dateRange = DateRange(lastDays:UInt(defaultOption.days))
        }else {
            dateRange = DateRange(fromDate: Date.init(timeIntervalSince1970: 0), toDate: Date())
        }
        
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        refreshHeader()
    }
}
