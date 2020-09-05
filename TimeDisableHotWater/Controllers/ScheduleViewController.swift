//
//  ScheduleViewController.swift
//  TimeDisableHotWater
//
//  Created by Vadim Denisov on 03.09.2020.
//  Copyright © 2020 Vadim Denisov. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController {

    private let tableView = UITableView()
    
    private var schedules: [Schedule] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()
        setupTableView()
        
        fetchSchedules()
    }
    
    private func setupNavigationItem() {
        navigationItem.title = "Сроки отключения горячей воды"
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    @objc private func fetchSchedules() {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
        NetworkManager.shared.fetchClassfiers { (classifiers, networkError) in
            guard let classifier = classifiers?.first else {
                DispatchQueue.main.async {
                    self.presentErrorAlert(message: "Возникла проблема c интернетом. Попробуйте еще раз")
                }
                return
            }
            NetworkManager.shared.fetchSchedules(classifier: classifier) { (schedules) in
                DispatchQueue.main.async {
                    guard let schedules = schedules else {
                        self.presentErrorAlert(message: "Возникла проблема с архивом. Попробуйте еще раз")
                        return
                    }
                    CoreDataManager.shared.deleteAllSchedules()
                    CoreDataManager.shared.insert(schedules: schedules)
                    
                    self.schedules = schedules
                    self.tableView.reloadData()
                    self.navigationItem.rightBarButtonItem = nil
                }
            }
        }
    }
    
    private func presentErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.fetchSchedules))
            CoreDataManager.shared.fetchSchedules { (schedulesBackup) in
                DispatchQueue.main.async {
                    self.schedules = schedulesBackup ?? []
                    self.tableView.reloadData()
                }
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
        
        var text = "\(schedule.locality) \(schedule.address)\n" + "дом \(schedule.houseNumber)"
        if !schedule.housing.isEmpty { text += " корпус \(schedule.housing)" }
        if !schedule.liter.isEmpty { text += " литер \(schedule.liter)" }
        text += "\n\(chageShoutdownPeriodFormat(shoutdownPeriod: schedule.shoutdownPeriod))"
        
        
        let cell = UITableViewCell()
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = text
        
        return cell
    }
    
}
