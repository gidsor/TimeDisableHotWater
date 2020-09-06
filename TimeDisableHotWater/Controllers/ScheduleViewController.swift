//
//  ScheduleViewController.swift
//  TimeDisableHotWater
//
//  Created by Vadim Denisov on 03.09.2020.
//  Copyright © 2020 Vadim Denisov. All rights reserved.
//

import UIKit

final class ScheduleViewController: UIViewController {

    private let tableView = UITableView()
    
    private var schedules: [Schedule] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()
        setupTableView()
        
        fetchSchedules()
    }
    
    private func setupNavigationItem() {
        navigationItem.title = AppStrings.scheduleViewTitle
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func presentErrorAlert(message: String) {
        let alertController = UIAlertController(title: AppStrings.error, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: AppStrings.ok, style: .default, handler: { _ in
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.fetchSchedules))
            CoreDataManager.shared.fetchSchedules { [weak self] (schedulesBackup) in
                self?.schedules = schedulesBackup ?? []
            }
        }))
        present(alertController, animated: true)
    }
    
    private func chageShoutdownPeriodFormat(shoutdownPeriod: String) -> String {
        let datesString = shoutdownPeriod.components(separatedBy: "-")
        let dates = datesString.compactMap { DateFormatter.serverShoutdownPeriodFormatter.date(from: $0) }
        let newDatesString = dates.compactMap { DateFormatter.localShoutdownPeriodFormatter.string(from: $0).replacingOccurrences(of: "г.", with: "") }
        return newDatesString.count == 2 ? "\(newDatesString[0]) - \(newDatesString[1])" : ""
    }
    
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let schedule = schedules[indexPath.row]
        
        var text = "\(schedule.locality) \(schedule.address)\n" + "\(AppStrings.house) \(schedule.houseNumber)"
        if !schedule.housing.isEmpty { text += " \(AppStrings.housing) \(schedule.housing)" }
        if !schedule.liter.isEmpty { text += " \(AppStrings.liter) \(schedule.liter)" }
        text += "\n\(chageShoutdownPeriodFormat(shoutdownPeriod: schedule.shoutdownPeriod))"
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = text
        
        return cell
    }
    
}

extension ScheduleViewController {
    
    @objc private func fetchSchedules() {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
        
        NetworkManager.shared.fetchClassfiers { [weak self] (classifiers, networkError) in
            guard let self = self else { return }
            
            guard let classifier = classifiers?.first else {
                self.presentErrorAlert(message: AppStrings.networkErrorMessage)
                return
            }
            
            ZipManager.unzip(base64Encoded: classifier.zipFileBase64Encoded) { [weak self] (data) in
                guard let self = self else { return }
                
                if let data = data, let schedules = try? JSONDecoder().decode(Array<Schedule>.self, from: data) {
                    CoreDataManager.shared.deleteAllSchedules()
                    CoreDataManager.shared.insert(schedules: schedules)
                    
                    self.schedules = schedules
                    self.navigationItem.rightBarButtonItem = nil
                } else {
                    self.presentErrorAlert(message: AppStrings.networkArchiveMessage)
                }
            }
        }
    }
    
}
