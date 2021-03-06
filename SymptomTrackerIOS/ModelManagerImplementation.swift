//
//  ModelManager.swift
//  SymptomTrackerIOS
//
//  Created by Kira Nim on 06/05/2022.
//

import Foundation
import SwiftUI

/* Responsibilities of the ModelManager:
The ModelManager manages business logic concerning model data that has been adapted to the system.
It manages the model-adapter classes (that takes care of CRUD).
Holds the model data classes adapted to be used throuhout the system.
Manages the Combine pipeline
 */


final class ModelManagerImplementation: ModelManager {
    
    //MARK: Repositories - Takes care of CRUD
    private let symptomRepository: SymptomRepository
    private let activityRepository: ActivityRepository
    private let symptomRegistrationRepository: SymptomRegistrationRepository
    private let intensityRegistrationRepository: IntensityRegistrationRepository
    private var firebaseSymptoms: [FirebaseSymptom] = []
    
    // Manages information about logged in user
    private let accountManager: AccountManager
    
    public let symptomsUpdatedNotificationName = NSNotification.Name("SymptomsUpdatedNotification")
    
    //MARK: Init
    init() {
        symptomRepository = SymptomRepository()
        activityRepository = ActivityRepository()
        symptomRegistrationRepository = SymptomRegistrationRepository()
        intensityRegistrationRepository = IntensityRegistrationRepository()
        accountManager = AccountManager()
        
        // If the user is still logged then the snapshot listener should be started.
        if let userId = self.accountManager.loggedInUserId {
            self.symptomRepository.startListener(loggedInUser: userId)
        }
        // always register callback, even if we don't fetch the symptoms immediately (we'll still need it after logging in)
        self.symptomRepository.callbacks.append(updateFirebaseSymptomList)
    }

    // MARK: Update symptomlist
    public func updateFirebaseSymptomList() {
        firebaseSymptoms = symptomRepository.firebaseSymptoms
        NotificationCenter.default.post(name: symptomsUpdatedNotificationName, object: nil)
    }
    
    // MARK Get logged in user
    public func isUserLoggedIn() -> Bool {
        return accountManager.isLoggedIn
    }
    
    // MARK: Symptom CRUD

    public func getSymptoms() -> [Symptom] {
        var symptomList: [Symptom] = firebaseSymptoms
        
        for item in symptomList {
            print(item.sortingPlacement)
        }
        symptomList.sort {
            $0.sortingPlacement < $1.sortingPlacement
        }
        return symptomList
    }
    
    public func updateSymptom(symptom: Symptom) {
        if let firebaseSymptom = symptom as? FirebaseSymptom {
            symptomRepository.update(symptom: firebaseSymptom)
        }
    }
    
    public func updateSymptoms(symptoms: [Symptom]) {
        // use compactMap to cast all symptoms from Symptom to FirebaseSymptom before saving them to db
        let firebaseSymptoms = symptoms.compactMap({ $0 as? FirebaseSymptom })
        symptomRepository.updateSymptoms(symptoms: firebaseSymptoms)
    }
    
    public func delete(symptom: Symptom) {
        if let firebaseSymptom = symptom as? FirebaseSymptom {
            symptomRepository.delete(symptom: firebaseSymptom)
        }
    }
    
    public func createSymptom(sortingPlacement: Int) -> Symptom? {
        if let userId = accountManager.loggedInUserId  {
            return FirebaseSymptom(sortingPlacement: sortingPlacement, userId: userId)
        } else {
            return nil
        }
    }
    
    // MARK: CRUD for Activities
    
    public func update(activity: Activity) {
        if let firebaseActivity = activity as? FirebaseActivity, let userId = accountManager.loggedInUserId {
            activityRepository.updateActivity(firebaseActivity: firebaseActivity, userId: userId)
        }
    }
    
    public func update(activities: [Activity]) {
        if let userId = accountManager.loggedInUserId{
            // use compactMap to cast all activities from Activity to Firebaseactivity before saving them to db
            let firebaseActivities = activities.compactMap({ $0 as? FirebaseActivity })
            activityRepository.updateActivities(activities: firebaseActivities, userId: userId)
        }
    }
    
    public func createActivity(date: Date) -> Activity? {
        if let userId = accountManager.loggedInUserId {
            return FirebaseActivity(userId: userId, date: date)
        } else {
            return nil
        }
    }
    
    public func delete(activity: Activity) {
        if let firebaseActivity = activity as? FirebaseActivity {
            activityRepository.delete(activity: firebaseActivity)
        }
    }
    
    public func getActivitiesForDate(date: Date,
                                     getActivitiesForDateCompletionCallback: @escaping (([Activity]) -> Void)) {

        if let userId = accountManager.loggedInUserId {
            activityRepository.getActivitiesFor(date: date, userId: userId) { firebaseActivityList in
                
                // Creating a new list because the firebaseActivityList is imutable (let)
                let newFirebaseList = firebaseActivityList.sorted {
                    $0.date > $1.date
                }
                getActivitiesForDateCompletionCallback(newFirebaseList)
            }
        }
    }
    
    public func getActivitiesForInterval(startDate: Date,
                                         endDate: Date,
                                         getActivitiesForIntervalCompletionCallback: @escaping (([Activity]) -> Void)) {

        if let userId = accountManager.loggedInUserId {
            activityRepository.getActivitiesForInterval(startDate: startDate, endDate: endDate, userId: userId) { firebaseActivityList in
                
                // Creating a new list because the firebaseActivityList is imutable (let)
                let newFirebaseList = firebaseActivityList.sorted {
                    $0.date > $1.date
                }
                getActivitiesForIntervalCompletionCallback(newFirebaseList)
            }
        }
    }
    
    // MARK: CRUD for Registrations
    
    public func getRegistrationsForDate(date: Date,
                                        getRegistrationsForDateCompletionCallback: @escaping (([SymptomRegistration]) -> Void)) {
        let registrationsService = RegistrationService()
        
        // If user is not logged in - should never happen
        if let userId = accountManager.loggedInUserId {
            
            symptomRegistrationRepository.getSymptomRegistrationsForDate(date: date, userId: userId) { firebaseSymptomRegistrationList in
                
                // Only make/fetch registrations for non-disabled symptoms
                let enabledSymptoms = self.firebaseSymptoms.filter { !$0.disabled }
                
                // registrationsService will return a list that has one registration for each symptom. If a registration does not exist in firebaseSymptomregistrationList, then a fresh registration will be generated and added to symptomRegistrationList.
                let symptomRegistrationsList = registrationsService.getSymptomRegistrationListFrom(
                                                        firebaseSymptomRegistrationList: firebaseSymptomRegistrationList,
                                                        symptomList: enabledSymptoms,
                                                        date: date)
                
                // Run callback passed from symptomRegistrationViewModel
                getRegistrationsForDateCompletionCallback(symptomRegistrationsList)
            }
        }
    }
    
    // function for getting all registrations in a time interval
    public func getRegistrationsForInterval(startDate: Date,
                                            endDate: Date,
                                            getRegistrationsForIntervalCompletionCallback: @escaping (([SymptomRegistration]) -> Void)) {
        let registrationsService = RegistrationService()
        
        // If user is not logged in - should never happen
        if let userId = accountManager.loggedInUserId {
            
            symptomRegistrationRepository.getSymptomRegistrationsForInterval(startDate: startDate, endDate: endDate, userId: userId) { firebaseSymptomRegistrationList in
                
                // Only make/fetch registrations for non-disabled symptoms
                let enabledSymptoms = self.firebaseSymptoms.filter { !$0.disabled }
                
                // registrationsService will return a list that has one registration for each symptom. If a registration does not exist in firebaseSymptomregistrationList, then a fresh registration will be generated and added to symptomRegistrationList.
                let symptomRegistrationsList = registrationsService.connectSymptonsAndRegistrations(
                    firebaseSymptomRegistrationList: firebaseSymptomRegistrationList,
                    symptomList: enabledSymptoms)
                
                // Run callback passed from symptomRegistrationViewModel
                getRegistrationsForIntervalCompletionCallback(symptomRegistrationsList)
            }
        }
    }
    
    // Update/save symptomRegistraytion to database.
    public func updateRegistration(symptomRegistration: SymptomRegistration) {
        if let firebaseSymptomRegistration = symptomRegistration as? FirebaseSymptomRegistration, let userId = accountManager.loggedInUserId {
            
            symptomRegistrationRepository.updateSymptomRegistration(firebaseSymptomRegistration: firebaseSymptomRegistration, userId: userId)
        }
    }
}

//MARK: Extension - AccountModelManager

// For logic concerning login/logout and create account
extension ModelManagerImplementation: AccountModelManager {
    
    //MARK: Create account
    
    public func createNewAccountWith(email: String, password: String, showErrorMessageFor: @escaping (AccountCreationResult) -> Void) {
        accountManager.createAccountWith(email: email, password: password) { errorMessage in
            // "getCreationResult(..)" returns the enum value used to determine which error message
            //(if any) should be passed to the view from the VM
            showErrorMessageFor(self.getCreationResult(errorMessage: errorMessage))
            
            if let loggedInUserId = self.accountManager.loggedInUserId {
                self.createDefaultSymptomListForDatabase(user: loggedInUserId)
                self.symptomRepository.startListener(loggedInUser: loggedInUserId)
            }
        }
    }
    
    public func createDefaultSymptomListForDatabase(user: String) {
        let defaultSymptomsNamesAndState = getDefaultSymptomNamesAndState()
                
        for (index, item) in defaultSymptomsNamesAndState.enumerated() {
            let document: [String:Any] = [
                "name": item.0,
                "disabled": item.1,
                "visibility_On_Graph": false,
                "sorting_placement": index,
                "user_id": user]
            
            symptomRepository.saveSymptomToDB(symptomDocument: document)
        }
    }
    
    // Method for translating error message (and nill) to enum "ErrorIdentifyer"
    public func getCreationResult(errorMessage: String?) -> AccountCreationResult {
        let errorMappingDict: [String: AccountCreationResult] = [
                "ERROR_INVALID_EMAIL": .invalidEmail,
                "ERROR_EMAIL_ALREADY_IN_USE": .emailAlreadyExist,
                "ERROR_WEAK_PASSWORD": .weakPasswordError]
        
        if let errorMessage = errorMessage {
            let creationResult = errorMappingDict[errorMessage] ?? .failed
            return creationResult
        }else {
            return .userCreated
        }
    }
        
    //MARK: Login
    
    public func loginWith(email: String, password: String, showErrorMessageFor: @escaping (AccountLoginResult) -> Void) {
        
        // "getLoginResult(..)" returns the enum value used to determine which error message
        // (if any) should be passed to the view from the VM
        accountManager.loginWith(email: email, password: password) { errorMessage in
            showErrorMessageFor(self.getLoginResult(errorMessage: errorMessage))
            
            if let userId = self.accountManager.loggedInUserId {
                self.symptomRepository.startListener(loggedInUser: userId)
            }
        }
    }
    
    public func getLoginResult(errorMessage: String?) -> AccountLoginResult {
        let errorMappingDict: [String: AccountLoginResult] = [
                "ERROR_USER_NOT_FOUND": .logInCredentialsNotValid,
                "ERROR_WRONG_PASSWORD": .logInCredentialsNotValid,
                "ERROR_INVALID_EMAIL": .logInCredentialsNotValid,
                "ERROR_USER_DISABLED": .accountDisabled]
        
        if let errorMessage = errorMessage {
            let loginResult = errorMappingDict[errorMessage] ?? .failed
            return loginResult
        }else {
            return .loginSucceded
        }
    }
    
    //MARK: Logout functionality
    
    public func logOut(logOutCompletionCallback: (() -> Void)?) {
        accountManager.logOut(logOutCompletionCallback: logOutCompletionCallback)
    }
    
    //MARK: Reset password functionality
    
    public func resetPassword(email: String) {
        accountManager.resetPassword(email: email)
    }
    
    //MARK: get default symptom tuples list
    private func getDefaultSymptomNamesAndState() -> [(String, Bool, Bool)]{
        return [(LocalizedStrings.shared.headache, false, true),
                (LocalizedStrings.shared.lightSensitivity, false, true),
                (LocalizedStrings.shared.extremeFatigue, false, true),
                (LocalizedStrings.shared.neckPain, false, false),
                (LocalizedStrings.shared.soundSensitivity, false, false),
                (LocalizedStrings.shared.impairedVision, false, false),
                (LocalizedStrings.shared.overactiveNervousSystem, false, false),
                (LocalizedStrings.shared.difficultyConcentrating, false, false),
                (LocalizedStrings.shared.mildAnxciety, true, false),
                (LocalizedStrings.shared.difficultiesUsingTheWorkingMemory, true, false),
                (LocalizedStrings.shared.difficultyPayingAttention, true, false),
                (LocalizedStrings.shared.moodChanges, true, false),
                (LocalizedStrings.shared.irritability, true, false),
                (LocalizedStrings.shared.slowResponsiveness, true, false),
                (LocalizedStrings.shared.stress, true, false),
                (LocalizedStrings.shared.dizziness, true, false),
                (LocalizedStrings.shared.nausea, true, false),
                (LocalizedStrings.shared.jointPain, true, false),
                (LocalizedStrings.shared.pressureInTheHead, true, false),
                (LocalizedStrings.shared.ringingInTheHead, true, false),
                (LocalizedStrings.shared.muscleTension, true, false),
                (LocalizedStrings.shared.alcoholIntolerance, true, false),
                (LocalizedStrings.shared.delayedFatigue, true, false),
                (LocalizedStrings.shared.quickExhaustion, true, false),
                (LocalizedStrings.shared.seizureFatigue, true, false),
                (LocalizedStrings.shared.stressFatigue, true, false),
                (LocalizedStrings.shared.alteredSleep, true, false),
                (LocalizedStrings.shared.insomnia, true, false),
                (LocalizedStrings.shared.hypersomnia, true, false),
                (LocalizedStrings.shared.learningDifficulties, true, false),
                (LocalizedStrings.shared.impairedVisionRegistration, true, false),
                (LocalizedStrings.shared.decisionFatigue, true, false),
                (LocalizedStrings.shared.slowThinking, true, false),
                (LocalizedStrings.shared.reducedSensoryFilter, true, false),
                (LocalizedStrings.shared.memoryProblems, true, false),
                (LocalizedStrings.shared.reducedExecutiveFunctions, true, false),
                (LocalizedStrings.shared.reducedReadinessForChange, true, false),
                (LocalizedStrings.shared.sadness, true, false),
                (LocalizedStrings.shared.severeAnxciety, true, false),
                (LocalizedStrings.shared.aggression, true, false),
                (LocalizedStrings.shared.difficultyWithEmotionalControl, true, false),
                (LocalizedStrings.shared.changedPersonality, true, false)]
    }
}




