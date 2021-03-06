//
//  InsightView.swift
//  SymptomTrackerIOS
//
//  Created by Kira Nim on 15/05/2022.
//

import Foundation
import UIKit
import Charts

class InsightView: UIView {
    
    // MARK: Subviews
    public let graphOuterContentView = UIView()
    public let graphInnerContentView = UIView()
    public let graphView = LineChartView()
    public let changeOrientationImage: UIImageView
    public let pieChartContentView = UIView()
    public let pieChart = PieChartView()
    public let segmentedControlContentView = UIView()
    public let segmentedControlView = UISegmentedControl(items: ["Uge", "Måned"])
    private var portraitGraphViewConstraints: [NSLayoutConstraint]?
    private var landscapeGraphViewConstraints: [NSLayoutConstraint]?
    
    // MARK: Init
    init() {
        var tintableImage: UIImage? = nil
        if let rotationImage = UIImage(named: "ScreenRotation") {
            tintableImage = rotationImage.withRenderingMode(.alwaysTemplate)
        }
        changeOrientationImage = UIImageView(image: tintableImage)
        changeOrientationImage.tintColor = UIColor.appColor(name: .buttonColor)
        
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.appColor(name: .backgroundColor)
        
        setAttributesOnSubViews()
        setupSubViews()
        setupConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Set attributes on subviews
    private func setAttributesOnSubViews() {
        segmentedControlView.selectedSegmentTintColor = UIColor.appColor(name: .graphSegmentedControlColor)
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appColor(name: .textBlack)]
        segmentedControlView.setTitleTextAttributes(titleTextAttributes, for: .normal)
        segmentedControlView.setTitleTextAttributes(titleTextAttributes, for: .selected)
        
        graphOuterContentView.translatesAutoresizingMaskIntoConstraints = false
        graphOuterContentView.backgroundColor = UIColor.appColor(name: .insightBackgroundColor)
        
        graphInnerContentView.translatesAutoresizingMaskIntoConstraints = false
        graphInnerContentView.backgroundColor = UIColor.appColor(name: .graphWhite)
        graphInnerContentView.layer.cornerRadius = 4
        graphInnerContentView.layer.borderWidth = 0.5
        
        graphView.translatesAutoresizingMaskIntoConstraints = false
        graphView.backgroundColor = UIColor.appColor(name: .graphWhite)
        
        changeOrientationImage.translatesAutoresizingMaskIntoConstraints = false
        changeOrientationImage.contentMode = .scaleAspectFit
        
        pieChartContentView.translatesAutoresizingMaskIntoConstraints = false
        pieChartContentView.backgroundColor = UIColor.appColor(name: .insightBackgroundColor)
        
        pieChart.translatesAutoresizingMaskIntoConstraints = false
        
        segmentedControlContentView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControlContentView.backgroundColor = UIColor.appColor(name: .insightBackgroundColor)
        
        segmentedControlView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControlView.backgroundColor = UIColor.appColor(name: .insightSegmentedControlBackgroundColor)
    }
    
    // MARK: Setup subviews
    private func setupSubViews() {
        segmentedControlContentView.addSubview(segmentedControlView)
        pieChartContentView.addSubview(pieChart)
        
        [segmentedControlContentView, graphInnerContentView].forEach({graphOuterContentView.addSubview($0)})
        
        // NB. Important that "graphView" is added next to last and that "changeOrientationImage" is added last
        [pieChartContentView, graphOuterContentView, graphView, changeOrientationImage].forEach({self.addSubview($0)})
    }
    
    // MARK: Setup constraints
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            graphOuterContentView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            graphOuterContentView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 33),
            graphOuterContentView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -33),
            graphOuterContentView.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: 70),
        
            segmentedControlContentView.topAnchor.constraint(equalTo: graphOuterContentView.topAnchor, constant: 40),
            segmentedControlContentView.leadingAnchor.constraint(equalTo: graphOuterContentView.leadingAnchor),
            segmentedControlContentView.trailingAnchor.constraint(equalTo: graphOuterContentView.trailingAnchor),
            segmentedControlContentView.heightAnchor.constraint(equalToConstant: 30),
            
            segmentedControlView.centerXAnchor.constraint(equalTo: segmentedControlContentView.centerXAnchor),
            segmentedControlView.topAnchor.constraint(equalTo: segmentedControlContentView.topAnchor),
            segmentedControlView.bottomAnchor.constraint(equalTo: segmentedControlContentView.bottomAnchor),
            segmentedControlView.leadingAnchor.constraint(equalTo: segmentedControlContentView.leadingAnchor, constant: 70),
            segmentedControlView.trailingAnchor.constraint(equalTo: segmentedControlView.trailingAnchor, constant: -70),
            
            graphInnerContentView.bottomAnchor.constraint(equalTo: graphOuterContentView.bottomAnchor),
            graphInnerContentView.leadingAnchor.constraint(equalTo: graphOuterContentView.leadingAnchor),
            graphInnerContentView.trailingAnchor.constraint(equalTo: graphOuterContentView.trailingAnchor),
            graphInnerContentView.topAnchor.constraint(equalTo: segmentedControlContentView.bottomAnchor, constant: 10),

            changeOrientationImage.bottomAnchor.constraint(equalTo: segmentedControlView.bottomAnchor),
            changeOrientationImage.trailingAnchor.constraint(equalTo: graphView.trailingAnchor, constant: -10),
            changeOrientationImage.heightAnchor.constraint(equalToConstant: 25),
            changeOrientationImage.widthAnchor.constraint(equalToConstant: 25),
            
            pieChart.centerYAnchor.constraint(equalTo: pieChartContentView.centerYAnchor),
            pieChart.centerXAnchor.constraint(equalTo: pieChartContentView.centerXAnchor),
            pieChart.heightAnchor.constraint(equalToConstant: 175),
            pieChart.widthAnchor.constraint(equalToConstant: 175),
             
            pieChartContentView.topAnchor.constraint(equalTo: graphOuterContentView.bottomAnchor, constant: 5),
            pieChartContentView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            pieChartContentView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 33),
            pieChartContentView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -33),
        ])
        
        let portraitGraphViewConstraints = [
            graphView.topAnchor.constraint(equalTo: graphInnerContentView.topAnchor),
            graphView.leadingAnchor.constraint(equalTo: graphInnerContentView.leadingAnchor),
            graphView.trailingAnchor.constraint(equalTo: graphInnerContentView.trailingAnchor),
            graphView.bottomAnchor.constraint(equalTo: graphInnerContentView.bottomAnchor),
        ]
        
        self.portraitGraphViewConstraints = portraitGraphViewConstraints
        
        landscapeGraphViewConstraints = [
            graphView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            graphView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            graphView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            graphView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
        ]
        
        NSLayoutConstraint.activate(portraitGraphViewConstraints)
    }
    
    public func setRotation(to isLandscape:Bool) {
        if isLandscape {
            setupConstraintsForLandscape()
        } else {
            setupConstraintsForPortrait()
        }
    }
    
    private func setupConstraintsForLandscape() {
        guard let portraitGraphViewConstraints = portraitGraphViewConstraints, let landscapeGraphViewConstraints = landscapeGraphViewConstraints  else { return }
        
        NSLayoutConstraint.deactivate(portraitGraphViewConstraints)
        NSLayoutConstraint.activate(landscapeGraphViewConstraints)
        
        bringSubviewToFront(graphView)
        pieChart.isHidden = true
    }
    
    private func setupConstraintsForPortrait(){
        guard let portraitGraphViewConstraints = portraitGraphViewConstraints, let landscapeGraphViewConstraints = landscapeGraphViewConstraints  else { return }
        
        NSLayoutConstraint.deactivate(landscapeGraphViewConstraints)
        NSLayoutConstraint.activate(portraitGraphViewConstraints)
        
        bringSubviewToFront(changeOrientationImage)
        pieChart.isHidden = false
    }
}
