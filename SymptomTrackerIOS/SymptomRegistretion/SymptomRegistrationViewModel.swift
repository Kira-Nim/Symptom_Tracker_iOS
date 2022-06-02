//
//  SymptomRegistrationViewModel.swift
//  SymptomTrackerIOS
//
//  Created by Kira Nim on 15/05/2022.
//

import Foundation
import UIKit

final class SymptomRegistrationViewModel: NSObject {
    public var modelManager: ModelManager
    private var view: SymptomRegistrationView?
    private var navbarView: UIView?
    private let cellReuseIdentifier =  "cellReuseIdentifier"
    private let symptomIntensityService = SymptomIntensityService()
    private var selectedDateRegistrations: [SymptomRegistration] = []
    private var nextDateRegistrations: [SymptomRegistration] = []
    private var previousDateRegistrations: [SymptomRegistration] = []
    private var currentDate: Date
    
    // MARK: Init
    init(modelManager: ModelManager) {
        self.modelManager = modelManager
        self.currentDate = Date()
    }
    
    public func setView(view: SymptomRegistrationView, navbarView: SymptomRegistrationNavbarView) {
        self.view = view
        self.navbarView = navbarView
        view.registrationTableView.delegate = self
        view.registrationTableView.dataSource = self
        
        // To make sure that a cell of type SymptomRegistrationCell is now available to the tableView.
        view.registrationTableView.register(SymptomRegistrationCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        navbarView.changeDateCallback = { date in
            self.changeToSelectedDate(chosenDate: date)
        }
        navbarView.getDateStringCallback = { date in
            let dateConverterService = DateConverterService()
            let dateString = dateConverterService.convertDateFrom(date: date)
            return dateString
        }
        self.view = view
    }
    
    // MARK: updateView()
    public func updateView() {
        view?.registrationTableView.reloadData()
    }
    
    // MARK: viewWillAppear
    public func viewWillAppear() {
        
        // called here because the SymptomRegistrations view data should be updated when changes
        // are made on other pages in the app
        updateSymptomRegistrationLists()
    }
    
    private func updateSymptomRegistrationLists() {
        // update list containing registrations for selected date
        modelManager.getRegistrationsForDate(date: currentDate) { symptomRegistrations in
            self.selectedDateRegistrations = symptomRegistrations
            self.updateView()
        }
        
        // If .date returns a non nil object for both metod calls get SymptomRegistration lists for previous and next date (compared to selected date)
        if let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate), let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
            
            modelManager.getRegistrationsForDate(date: nextDate){ symptomRegistrations in
                
                symptomRegistrations.forEach({ symptomRegistration in
                    if symptomRegistration.symptom?.disabled == false {
                        self.nextDateRegistrations.append(symptomRegistration)
                    }
                })
            }
            
            modelManager.getRegistrationsForDate(date: previousDate){ symptomRegistrations in
                
                symptomRegistrations.forEach({ symptomRegistration in
                    if symptomRegistration.symptom?.disabled == false {
                        self.previousDateRegistrations.append(symptomRegistration)
                    }
                })
            }
        }
    }
    
    private func updateSymptomRegistrationListFor(date: Date, list: [SymptomRegistration]) {
        var list = list
        modelManager.getRegistrationsForDate(date: date){ symptomRegistrations in
            symptomRegistrations.forEach({ symptomRegistration in
                if symptomRegistration.symptom?.disabled == false {
                    list.append(symptomRegistration)
                }
            })
        }
    }
    
    public func changeToSelectedDate(chosenDate: Date) {
        guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate),
              let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) else {return}
        
        if chosenDate == nextDate {
            nextDateRegistrations = selectedDateRegistrations
            selectedDateRegistrations = previousDateRegistrations
            
            if let previousToChosenDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) {
                updateSymptomRegistrationListFor(date: previousToChosenDate, list: previousDateRegistrations)
            }
        } else if chosenDate == previousDate {
            previousDateRegistrations = selectedDateRegistrations
            selectedDateRegistrations = nextDateRegistrations
            
            if let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
                updateSymptomRegistrationListFor(date: nextDate, list: nextDateRegistrations)
            }
        } else {
            currentDate = chosenDate
            updateSymptomRegistrationLists()
        }
        
        currentDate = chosenDate
    }
}




extension SymptomRegistrationViewModel: UITableViewDelegate {
}

extension SymptomRegistrationViewModel: UITableViewDataSource {
    
    // How many sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // How many rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedDateRegistrations.count
    }
    
    // Method responsible for declaring whitch cell type should be used for each row and for configuring that cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        
        if let symptomRegistrationCell = cell as?  SymptomRegistrationCell {
            symptomRegistrationCell.configureCell(symptomRegistration: selectedDateRegistrations[indexPath.row],
                                                  presentRegistrationIntensityCallback: symptomIntensityService.getIntensityColorForRegistration) { symptomRegistration in
                self.modelManager.updateRegistration(symptomRegistration: symptomRegistration)
            }
        }
        return cell
    }
    
    // Method for configuring row height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 97
    }
}
