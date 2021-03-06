//
//  SymptomListController.swift
//  SymptomTrackerIOS
//
//  Created by Kira Nim on 21/05/2022.
//

import Foundation
import UIKit

final class SymptomListViewController: UIViewController {
    private var symptomListViewModel: SymptomListViewModel
    private lazy var symptomListView = SymptomListView()
    
    init(viewModel: SymptomListViewModel, showEditNavbarItem: Bool = true) {
        symptomListViewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        title = LocalizedStrings.shared.symptomListControllerTitle
        
        if showEditNavbarItem {
            navigationItem.rightBarButtonItem = editButtonItem
        }
    }
    
    override func setEditing(_ state:Bool, animated: Bool) {
        super.setEditing(state, animated: animated)
        symptomListViewModel.setEditing(state, animated: animated)
    }
    
    //Formel requirement for all ViewControllers to have this initializer.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: loadView()
    override func loadView() {
        view = symptomListView
    }
    
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        symptomListViewModel.setView(view: symptomListView)
    }
    
    // MARK: ViewWillAppear()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        symptomListViewModel.updateView()
    }
}
