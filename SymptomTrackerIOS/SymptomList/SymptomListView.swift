//
//  SymptomListView.swift
//  SymptomTrackerIOS
//
//  Created by Kira Nim on 21/05/2022.
//

import Foundation
import UIKit

final class SymptomListView: UIView {
    public var buttonContentViewConstraint: NSLayoutConstraint?
    public var createSymptomButtonViewConstraint: NSLayoutConstraint?
    
    //MARK: Subviews
    public var symptomsTableView: UITableView = UITableView()
    public var createSymptomButtonView = UIButton()
    
    public lazy var buttonContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.appColor(name: .sectionBacgroundColor)
        return view
    }()
    
    // MARK: - Initializer
    init() {
        /*
        The frame of the super view to this view, is temperarily set to zero
         until this view is placed into the view hierarchy and this this super
         view gets its real freme bounds from the OS (when the controller ordered to show its view)
        */
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.appColor(name: .backgroundColor)
        
        // Because we only want these elements to be shown to user when list is in editing stete
        self.buttonContentViewConstraint = buttonContentView.heightAnchor.constraint(equalToConstant: 0)
        self.createSymptomButtonViewConstraint = createSymptomButtonView.heightAnchor.constraint(equalToConstant: 0)

        setAttributesOnSubViews()
        setupSubViews()
        setupConstraints()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Set attributesOn subviews
    private func setAttributesOnSubViews() {
        symptomsTableView.translatesAutoresizingMaskIntoConstraints = false
        symptomsTableView.backgroundColor = UIColor.appColor(name: .backgroundColor)
        
        createSymptomButtonView.translatesAutoresizingMaskIntoConstraints = false
        createSymptomButtonView.setTitle(LocalizedStrings.shared.createSymptomButtonText, for: .normal)
        createSymptomButtonView.setTitleColor(UIColor.appColor(name: .buttonTextColor), for: .normal)
        createSymptomButtonView.titleLabel?.font = .appFont(ofSize: 17, weight: .medium)
        createSymptomButtonView.backgroundColor = .appColor(name: .buttonColor)
        createSymptomButtonView.setBackgroundImage(UIColor.appColor(name: .buttonClicked).image(), for: .highlighted)
        createSymptomButtonView.layer.cornerRadius = 3
        createSymptomButtonView.layer.borderWidth = 1
        createSymptomButtonView.layer.borderColor = UIColor.appColor(name: .buttonBorderColor).cgColor
        
    }
    
    // MARK: Setup SubViews
    private func setupSubViews() {
        buttonContentView.addSubview(createSymptomButtonView)
        [buttonContentView, symptomsTableView].forEach({self.addSubview($0)})
    }
    
    // MARK: Setup constraints
    private func setupConstraints() {
        if let buttonContentViewConstraint = buttonContentViewConstraint,
           let createSymptomButtonViewConstraint = createSymptomButtonViewConstraint {
            NSLayoutConstraint.activate([buttonContentViewConstraint, createSymptomButtonViewConstraint])
        }
        
        NSLayoutConstraint.activate([
            buttonContentView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 5),
            buttonContentView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            buttonContentView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            
            createSymptomButtonView.leadingAnchor.constraint(equalTo: buttonContentView.leadingAnchor, constant: 115),
            createSymptomButtonView.trailingAnchor.constraint(equalTo: buttonContentView.trailingAnchor, constant: -115),
            createSymptomButtonView.centerYAnchor.constraint(equalTo: buttonContentView.centerYAnchor, constant: 3),
            
            symptomsTableView.topAnchor.constraint(equalTo: buttonContentView.bottomAnchor, constant: 5),
            symptomsTableView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            symptomsTableView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            symptomsTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
